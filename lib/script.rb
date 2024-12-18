require "net/http"
require "uri"
require "json"
require "digest"
require "fileutils"
require "open3"

PROJECT_DIR = "/home/ubuntu/project"
TEST_OUTPUT_FILENAME = "tmp/test_output.txt"
TEST_RESULTS_FILENAME = "tmp/test_results.txt"

class Script
  def self.execute
    client = SaturnCIRunnerAPI::Client.new(ENV["HOST"])

    puts "Starting to stream system logs"
    SaturnCIRunnerAPI::Stream.new(
      "/var/log/syslog",
      "runs/#{ENV["RUN_ID"]}/system_logs"
    ).start

    puts "Runner ready"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "runner_ready")

    token = client.post("github_tokens", github_installation_id: ENV["GITHUB_INSTALLATION_ID"]).body
    _, stderr, status = Open3.capture3("git clone https://x-access-token:#{token}@github.com/#{ENV['GITHUB_REPO_FULL_NAME']} #{PROJECT_DIR}")

    if status.success?
      puts "Clone of #{ENV["GITHUB_REPO_FULL_NAME"]} into #{PROJECT_DIR} successful"
    else
      puts "Clone of #{ENV["GITHUB_REPO_FULL_NAME"]} into #{PROJECT_DIR} failed: #{stderr}"
    end

    Dir.chdir(PROJECT_DIR)
    FileUtils.mkdir_p('tmp')

    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "repository_cloned")

    puts "Checking out commit #{ENV["COMMIT_HASH"]}"
    system("git checkout #{ENV["COMMIT_HASH"]}")

    gemfile_lock_checksum = Digest::SHA256.file("Gemfile.lock").hexdigest
    registry_cache_url = "registrycache.saturnci.com:5000"

    registry_cache_image_url = "#{registry_cache_url}/saturn_test_app:#{gemfile_lock_checksum}"

    # Registry cache IP is sometimes wrong without this.
    system("sudo systemd-resolve --flush-caches")

    puts "Authenticating to Docker registry (#{registry_cache_url})"
    system("sudo docker login #{registry_cache_url} -u myusername -p mypassword")

    puts "Pulling the existing image to avoid rebuilding if possible"
    system("sudo docker pull #{registry_cache_image_url} || true")

    puts "Running pre.sh"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "pre_script_started")
    system("sudo chmod 755 .saturnci/pre.sh")

    docker_compose_configuration = SaturnCIRunnerAPI::DockerComposeConfiguration.new(
      registry_cache_image_url: registry_cache_image_url,
      env_vars: ENV["USER_ENV_VAR_KEYS"].split(",").map { |key| [key, ENV[key]] }.to_h
    )

    pre_script_command = SaturnCIRunnerAPI::PreScriptCommand.new(
      docker_compose_configuration: docker_compose_configuration
    )
    puts "pre.sh command: #{pre_script_command.to_s}"
    system(pre_script_command.to_s)
    puts "pre.sh exit code: #{$?.exitstatus}"

    if $?.exitstatus == 0
      client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "pre_script_finished")
    else
      exit 1
    end

    puts "Starting to stream test output"
    File.open(TEST_OUTPUT_FILENAME, 'w') {}

    SaturnCIRunnerAPI::Stream.new(
      TEST_OUTPUT_FILENAME,
      "runs/#{ENV["RUN_ID"]}/test_output"
    ).start

    puts "Running tests"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "test_suite_started")

    File.open('./example_status_persistence.rb', 'w') do |file|
      file.puts "RSpec.configure do |config|"
      file.puts "  config.example_status_persistence_file_path = '#{TEST_RESULTS_FILENAME}'"
      file.puts "end"
    end

    test_files = Dir.glob('./spec/**/*_spec.rb')
    chunks = test_files.each_slice((test_files.size / ENV['NUMBER_OF_CONCURRENT_RUNS'].to_i.to_f).ceil).to_a
    selected_tests = chunks[ENV['JOB_ORDER_INDEX'].to_i - 1]
    test_files_string = selected_tests.join(' ')

    command = SaturnCIRunnerAPI::TestSuiteCommand.new(
      docker_compose_configuration: docker_compose_configuration,
      test_files_string: test_files_string,
      rspec_seed: ENV["RSPEC_SEED"],
      test_output_filename: TEST_OUTPUT_FILENAME
    ).to_s
    puts "Test run command: #{command}"

    pid = Process.spawn(command)
    Process.wait(pid)
    sleep(5)

    puts "Run finished"
    client.post("runs/#{ENV["RUN_ID"]}/run_finished_events")

    puts "Sending report"
    test_reports_request = SaturnCIRunnerAPI::FileContentRequest.new(
      host: ENV["HOST"],
      api_path: "runs/#{ENV["RUN_ID"]}/test_reports",
      content_type: "text/plain",
      file_path: TEST_RESULTS_FILENAME
    )
    test_reports_request.execute

    puts `$(sudo docker image ls)`

    puts "Performing docker tag and push"
    system("sudo docker tag #{registry_cache_url}/saturn_test_app #{registry_cache_image_url}")
    system("sudo docker push #{registry_cache_image_url}")
    puts "Docker push finished"

    puts "Deleting runner"
    sleep(5)
    client.delete("runs/#{ENV["RUN_ID"]}/runner")
  end
end

if ENV["RUN_ID"]
  Script.execute
end
