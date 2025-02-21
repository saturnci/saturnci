require "net/http"
require "uri"
require "json"
require "fileutils"

PROJECT_DIR = "/home/ubuntu/project"
RSPEC_DOCUMENTATION_OUTPUT_FILENAME = "tmp/rspec_documentation_output.txt"
TEST_RESULTS_FILENAME = "tmp/test_results.txt"

class Script
  def self.execute
    client = SaturnCIRunnerAPI::Client.new(ENV["HOST"])

    puts "Starting to stream system logs"
    system_log_stream = SaturnCIRunnerAPI::Stream.new(
      "/var/log/syslog",
      "runs/#{ENV["RUN_ID"]}/system_logs"
    )
    system_log_stream.start

    puts "Runner ready"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "runner_ready")

    clone_repo(client: client, source: ENV["GITHUB_REPO_FULL_NAME"], destination: PROJECT_DIR)

    Dir.chdir(PROJECT_DIR)
    FileUtils.mkdir_p('tmp')

    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "repository_cloned")

    puts "Checking out commit #{ENV["COMMIT_HASH"]}"
    system("git checkout #{ENV["COMMIT_HASH"]}")

    docker_registry_cache = SaturnCIRunnerAPI::DockerRegistryCache.new(
      username: ENV["DOCKER_REGISTRY_CACHE_USERNAME"],
      password: ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]
    )

    puts "Docker registry cache checksum: #{docker_registry_cache.checksum}"
    puts "Registry cache image URL: #{docker_registry_cache.image_url}"
    system("echo 'SATURN_TEST_APP_IMAGE_URL=#{docker_registry_cache.image_url}' >> /tmp/saturnci.env")

    puts "Authenticating to Docker registry (#{SaturnCIRunnerAPI::DockerRegistryCache::URL})"
    docker_registry_cache.authenticate

    puts "Pulling the existing image to avoid rebuilding if possible"
    puts docker_registry_cache.pull_image

    puts "Copying database.yml"
    system("sudo cp .saturnci/database.yml config/database.yml")

    puts "Running pre.sh"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "pre_script_started")
    system("sudo chmod 755 .saturnci/pre.sh")

    docker_compose_configuration = SaturnCIRunnerAPI::DockerComposeConfiguration.new(
      docker_registry_cache_image_url: docker_registry_cache.image_url,
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
    File.open(RSPEC_DOCUMENTATION_OUTPUT_FILENAME, 'w') {}

    SaturnCIRunnerAPI::Stream.new(
      RSPEC_DOCUMENTATION_OUTPUT_FILENAME,
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
    selected_tests = chunks[ENV['RUN_ORDER_INDEX'].to_i - 1]
    test_files_string = selected_tests.join(' ')

    test_suite_command = SaturnCIRunnerAPI::TestSuiteCommand.new(
      docker_compose_configuration: docker_compose_configuration,
      test_files_string: test_files_string,
      rspec_seed: ENV["RSPEC_SEED"],
      rspec_documentation_output_filename: RSPEC_DOCUMENTATION_OUTPUT_FILENAME
    ).to_s
    puts "Test run command: #{test_suite_command}"

    test_suite_pid = Process.spawn(test_suite_command)
    Process.wait(test_suite_pid)
    sleep(5)

    puts "Sending JSON output"
    test_output_request = SaturnCIRunnerAPI::FileContentRequest.new(
      host: ENV["HOST"],
      api_path: "runs/#{ENV["RUN_ID"]}/json_output",
      content_type: "application/json",
      file_path: "tmp/json_output.json"
    )
    response = test_output_request.execute
    puts "JSON output response code: #{response.code}"
    puts response.body
    puts

    puts "Sending report"
    test_reports_request = SaturnCIRunnerAPI::FileContentRequest.new(
      host: ENV["HOST"],
      api_path: "runs/#{ENV["RUN_ID"]}/test_reports",
      content_type: "text/plain",
      file_path: TEST_RESULTS_FILENAME
    )
    response = test_reports_request.execute
    puts "Report response code: #{response.code}"
    puts response.body
    puts

    puts "Run finished"
    response = client.post("runs/#{ENV["RUN_ID"]}/run_finished_events")
    puts "Run finished response code: #{response.code}"
    puts response.body
    puts

    send_screenshot_tar_file(source_dir: "tmp/capybara")

    puts "$(sudo docker image ls)"
    puts `$(sudo docker image ls)`

    puts "Performing docker tag and push"
    docker_registry_cache.push_image
    puts "Docker push finished"

  rescue StandardError => e
    puts "Error: #{e.message}"
    puts e.backtrace
  ensure
    puts "Deleting runner"
    sleep(5)
    system_log_stream.kill
    client.delete("runs/#{ENV["RUN_ID"]}/runner")
  end

  def self.clone_repo(client:, source:, destination:)
    require "open3"
    puts "Cloning #{source} into #{destination}..."
    token = client.post("github_tokens", github_installation_id: ENV["GITHUB_INSTALLATION_ID"]).body
    _, stderr, status = Open3.capture3("git clone --recurse-submodules https://x-access-token:#{token}@github.com/#{source} #{destination}")
    puts status.success? ? "clone successful" : "clone failed: #{stderr}"
  end

  def self.send_screenshot_tar_file(source_dir:)
    unless Dir.exist?(source_dir)
      puts "No screenshots found in #{source_dir}"
      return
    end

    screenshot_tar_file = SaturnCIRunnerAPI::ScreenshotTarFile.new(source_dir: source_dir)
    puts "Screenshots tarred at: #{screenshot_tar_file.path}"

    screenshot_upload_request = SaturnCIRunnerAPI::FileContentRequest.new(
      host: ENV["HOST"],
      api_path: "runs/#{ENV["RUN_ID"]}/screenshots",
      content_type: "application/tar",
      file_path: screenshot_tar_file.path
    )

    response = screenshot_upload_request.execute
    puts "Screenshot tar response code: #{response.code}"
    puts response.body
  end
end

if ENV["RUN_ID"]
  Script.execute
end
