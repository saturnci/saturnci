require "net/http"
require "uri"
require "json"
require "fileutils"

PROJECT_DIR = "/home/ubuntu/project"
RSPEC_DOCUMENTATION_OUTPUT_FILENAME = "tmp/rspec_documentation_output.txt"
TEST_RESULTS_FILENAME = "tmp/test_results.txt"

class Script
  def self.execute
    $stdout.sync = true

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
    FileUtils.mkdir_p("tmp")

    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "repository_cloned")

    puts "Checking out commit #{ENV["COMMIT_HASH"]}"
    system("git checkout #{ENV["COMMIT_HASH"]}")

    docker_registry_cache = SaturnCIRunnerAPI::DockerRegistryCache.new(
      username: ENV["DOCKER_REGISTRY_CACHE_USERNAME"],
      password: ENV["DOCKER_REGISTRY_CACHE_PASSWORD"],
      project_name: ENV["PROJECT_NAME"].downcase,
      branch_name: ENV["BRANCH_NAME"].downcase
    )

    puts "Registry cache image URL: #{docker_registry_cache.image_url}"
    system("echo 'export SATURN_TEST_APP_IMAGE_URL=#{docker_registry_cache.image_url}' >> #{ENV["SATURNCI_ENV_FILE_PATH"]}")
    system("echo 'export DOCKER_BUILDKIT=1' >> #{ENV["SATURNCI_ENV_FILE_PATH"]}")
    system("source #{ENV["SATURNCI_ENV_FILE_PATH"]}")
    system("cp #{ENV["SATURNCI_ENV_FILE_PATH"]} #{PROJECT_DIR}/.saturnci/.env")
    system("export $(cat #{PROJECT_DIR}/.saturnci/.env | xargs)")

    puts "Environment variables set in this shell:"
    system("env | awk -F= '{print $1}' | sort")

    puts "Attempting to authenticate to Docker registry (#{SaturnCIRunnerAPI::DockerRegistryCache::URL})"

    if docker_registry_cache.authenticate
      puts "Docker registry cache authentication successful"
    else
      raise "Docker registry cache authentication failed"
    end

    puts "Copying database.yml"
    system("sudo cp .saturnci/database.yml config/database.yml")

    build_args = []
    build_args << "--build-arg ARCH=#{ENV["ARCH"]}" if ENV["ARCH"]
    build_args << "--build-arg NODE_ARCH=#{ENV["NODE_ARCH"]}" if ENV["NODE_ARCH"]
    build_args << "--build-arg BUNDLE_GEMFILE=#{ENV["BUNDLE_GEMFILE"]}" if ENV["BUNDLE_GEMFILE"]

    system("docker buildx create --name saturnci-builder --driver docker-container --use")

    build_command = "docker buildx build \
      --push \
      -t #{docker_registry_cache.image_url}:latest \
      #{build_args.join(" ")} \
      --cache-from type=registry,ref=#{docker_registry_cache.image_url}:cache \
      --cache-to type=registry,ref=#{docker_registry_cache.image_url}:cache,mode=max \
      --progress=plain \
      -f .saturnci/Dockerfile ."

    puts "Build command: #{build_command}"
    build_command_result = system(build_command)
    if build_command_result
      puts "Build command completed successfully"
    else
      raise "Build command failed"
    end

    puts "Running pre.sh"
    client.post("runs/#{ENV["RUN_ID"]}/run_events", type: "pre_script_started")
    system("sudo chmod 755 .saturnci/pre.sh")

    pre_script_command = "docker-compose -f .saturnci/docker-compose.yml run saturn_test_app ./.saturnci/pre.sh"
    puts "pre.sh command: \"#{pre_script_command}\""
    system(pre_script_command)
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

    test_files = Dir.glob("./spec/**/*_spec.rb").shuffle(random: Random.new(ENV["RSPEC_SEED"].to_i))
    chunks = test_files.each_slice((test_files.size / ENV["NUMBER_OF_CONCURRENT_RUNS"].to_i.to_f).ceil).to_a
    selected_tests = chunks[ENV["RUN_ORDER_INDEX"].to_i - 1]
    test_files_string = selected_tests.join(" ")

    test_suite_command = SaturnCIRunnerAPI::TestSuiteCommand.new(
      docker_registry_cache_image_url: docker_registry_cache.image_url,
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

    send_screenshot_tar_file(source_dir: "tmp/capybara")

  rescue StandardError => e
    puts "Error: #{e.message}"
    puts e.backtrace
  ensure
    puts "Run finished"
    response = client.post("runs/#{ENV["RUN_ID"]}/run_finished_events")
    puts "Run finished response code: #{response.code}"
    puts response.body
    puts

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
