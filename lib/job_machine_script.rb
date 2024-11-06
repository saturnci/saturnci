require "net/http"
require "uri"
require "json"
require "digest"
require "fileutils"

PROJECT_DIR = "/home/ubuntu/project"
TEST_OUTPUT_FILENAME = "tmp/test_output.txt"
TEST_RESULTS_FILENAME = "tmp/test_results.txt"

module JobMachineScript
  class Request
    def initialize(host, method, endpoint, payload = nil)
      @host = host
      @method = method
      @endpoint = endpoint
      @payload = payload
    end

    def execute
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == "https"
      http.request(request)
    end

    def request
      case @method
      when :post
        r = Net::HTTP::Post.new(url)
      when :delete
        r = Net::HTTP::Delete.new(url)
      end

      r.basic_auth(ENV["SATURNCI_API_USERNAME"], ENV["SATURNCI_API_PASSWORD"])
      r["Content-Type"] = "application/json"
      r.body = @payload.to_json if @payload
      r
    end

    private

    def url
      URI("#{@host}/api/v1/#{@endpoint}")
    end
  end

  class ContentRequest
    def initialize(host:, api_path:, content_type:, content:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @content = content
    end

    def execute
      command = <<~COMMAND
        curl -s -f -u #{ENV["SATURNCI_API_USERNAME"]}:#{ENV["SATURNCI_API_PASSWORD"]} \
            -X POST \
            -H "Content-Type: #{@content_type}" \
            -d "#{@content}" #{url}
      COMMAND

      system(command)
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end

  class FileContentRequest
    def initialize(host:, api_path:, content_type:, file_path:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @file_path = file_path
    end

    def execute
      command = <<~COMMAND
        curl -s -f -u #{ENV["SATURNCI_API_USERNAME"]}:#{ENV["SATURNCI_API_PASSWORD"]} \
            -X POST \
            -H "Content-Type: #{@content_type}" \
            --data-binary "@#{@file_path}" #{url}
      COMMAND

      system(command)
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end

  class Client
    def initialize(host)
      @host = host
    end

    def post(endpoint, payload = nil)
      Request.new(@host, :post, endpoint, payload).execute
    end

    def delete(endpoint)
      Request.new(@host, :delete, endpoint).execute
    end

    def debug(message)
      post("debug_messages", message)
    end
  end

  class RSpecCommand
    def initialize(registry_cache_image_url:, test_files_string:, rspec_seed:, test_output_filename:)
      @registry_cache_image_url = registry_cache_image_url
      @test_files_string = test_files_string
      @rspec_seed = rspec_seed
      @test_output_filename = test_output_filename
    end

    def to_s
      "script -f #{@test_output_filename} -c \"sudo SATURN_TEST_APP_IMAGE_URL=#{@registry_cache_image_url} #{docker_compose_command.strip}\""
    end

    private

    def docker_compose_command
      "docker-compose -f .saturnci/docker-compose.yml run saturn_test_app #{rspec_command}"
    end

    def rspec_command
      "bundle exec rspec --require ./example_status_persistence.rb --format=documentation --order rand:#{@rspec_seed} #{@test_files_string}"
    end
  end
end

def stream(log_file_path, api_path, client)
  Thread.new do
    last_line = 0

    while true
      current_number_of_lines_in_log_file = File.read(log_file_path).lines.count

      if current_number_of_lines_in_log_file > last_line
        content = File.readlines(log_file_path)[last_line..-1].join
        client.debug "1234 Content: #{content[0..100]}"

        JobMachineScript::ContentRequest.new(
          host: ENV["HOST"],
          api_path: api_path,
          content_type: "text/plain",
          content: content
        ).execute

        last_line = current_number_of_lines_in_log_file
      end

      sleep(1)
    end
  end
end

def stream2(log_file_path, api_path, client)
  Thread.new do
    most_recent_total_line_count = 0

    while true
      all_lines = File.readlines(log_file_path)
      newest_content = all_lines[most_recent_total_line_count..-1].join("\n")

      #client.debug "1234 last line index: #{most_recent_total_line_count} total count: #{all_lines.count}"
      #client.debug "1234 Content: #{newest_content[0..300]}"

      JobMachineScript::ContentRequest.new(
        host: ENV["HOST"],
        api_path: api_path,
        content_type: "text/plain",
        content: "#{newest_content[0..1000]}\n"
      ).execute

      most_recent_total_line_count = all_lines.count

      sleep(1)
    end  
  end
end

if ENV["JOB_ID"]
  client = JobMachineScript::Client.new(ENV["HOST"])
  client.debug "1234 Starting to stream system logs"
  client.debug "1234 Sending system log to #{ENV["HOST"]}/api/v1/jobs/#{ENV["JOB_ID"]}/system_logs"

  #puts "Starting to stream system logs"
  #system_log_streaming_thread = stream("/var/log/syslog", "jobs/#{ENV["JOB_ID"]}/system_logs", client)

  stream2("/var/log/syslog", "jobs/#{ENV["JOB_ID"]}/system_logs", client)

  puts "Job machine ready"
  client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "job_machine_ready")

  token = client.post("github_tokens", github_installation_id: ENV["GITHUB_INSTALLATION_ID"]).body
  system("git clone https://x-access-token:#{token}@github.com/#{ENV['GITHUB_REPO_FULL_NAME']} #{PROJECT_DIR}")
  Dir.chdir(PROJECT_DIR)
  FileUtils.mkdir_p('tmp')

  client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "repository_cloned")

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
  client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "pre_script_started")
  system("sudo chmod 755 .saturnci/pre.sh")
  system("sudo SATURN_TEST_APP_IMAGE_URL=#{registry_cache_image_url} docker-compose -f .saturnci/docker-compose.yml run saturn_test_app ./.saturnci/pre.sh")
  client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "pre_script_finished")

  puts "Starting to stream test output"
  File.open(TEST_OUTPUT_FILENAME, 'w') {}

  #streaming_thread = stream(TEST_OUTPUT_FILENAME, "jobs/#{ENV["JOB_ID"]}/test_output")
  stream2(TEST_OUTPUT_FILENAME, "jobs/#{ENV["JOB_ID"]}/test_output", client)

  puts "Running tests"
  puts "jobs/#{ENV["JOB_ID"]}/test_suite_started"
  client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "test_suite_started")

  File.open('./example_status_persistence.rb', 'w') do |file|
    file.puts "RSpec.configure do |config|"
    file.puts "  config.example_status_persistence_file_path = '#{TEST_RESULTS_FILENAME}'"
    file.puts "end"
  end

  test_files = Dir.glob('./spec/**/*_spec.rb')
  chunks = test_files.each_slice((test_files.size / ENV['NUMBER_OF_CONCURRENT_JOBS'].to_i.to_f).ceil).to_a
  selected_tests = chunks[ENV['JOB_ORDER_INDEX'].to_i - 1]
  test_files_string = selected_tests.join(' ')

  command = JobMachineScript::RSpecCommand.new(
    registry_cache_image_url: registry_cache_image_url,
    test_files_string: test_files_string,
    rspec_seed: ENV["RSPEC_SEED"],
    test_output_filename: TEST_OUTPUT_FILENAME
  ).to_s
  puts command

  system(command)

  # Without this sleep, there's a race condition between the
  # test output stream finishing and the job_finished event
  sleep(5)

  puts "Job finished"
  client.post("jobs/#{ENV["JOB_ID"]}/job_finished_events")

  puts "Sending report"
  test_reports_request = JobMachineScript::FileContentRequest.new(
    host: ENV["HOST"],
    api_path: "jobs/#{ENV["JOB_ID"]}/test_reports",
    content_type: "text/plain",
    file_path: TEST_RESULTS_FILENAME
  )
  test_reports_request.execute

  puts `$(sudo docker image ls)`

  puts "Performing docker tag and push"
  system("sudo docker tag #{registry_cache_url}/saturn_test_app #{registry_cache_image_url}")
  system("sudo docker push #{registry_cache_image_url}")
  puts "Docker push finished"

  puts "Deleting job machine"
  client.delete("jobs/#{ENV["JOB_ID"]}/job_machine")

  streaming_thread.join if streaming_thread.alive?
end
