#!/bin/bash

export USER_DIR=/home/ubuntu
export PROJECT_DIR=$USER_DIR/project
export SYSTEM_LOG_FILENAME=/var/log/syslog
export TEST_OUTPUT_FILENAME=tmp/test_output.txt
export TEST_RESULTS_FILENAME=tmp/test_results.txt

function api_request() {
    local method=$1
    local path=$2
    local data=$3

    curl -s -f -u $SATURNCI_API_USERNAME:$SATURNCI_API_PASSWORD \
        -X $method \
        -H "Content-Type: application/json" \
        -d "$data" \
        $HOST/api/v1/$path
}

function send_content_to_api() {
    local api_path=$1
    local content_type=$2
    local content=$3

    curl -s -f -u $SATURNCI_API_USERNAME:$SATURNCI_API_PASSWORD \
        -X POST \
        -H "Content-Type: $content_type" \
        -d "$content" "$HOST/api/v1/$api_path"
}

function clone_user_repo() {
  TOKEN=$(api_request "POST" "github_tokens" "{\"github_installation_id\":\"$GITHUB_INSTALLATION_ID\"}")
  git clone https://x-access-token:$TOKEN@github.com/$GITHUB_REPO_FULL_NAME $PROJECT_DIR
  cd $PROJECT_DIR
  mkdir tmp
}

function stream_logs() {
    local api_path=$1
    local log_file_path=$2
    local last_line=0
    local log_sending_interval_in_seconds=1

    while true; do
        local current_number_of_lines_in_log_file=$(wc -l < $log_file_path)
        if [ $current_number_of_lines_in_log_file -gt $last_line ]; then
            local content=$(sed -n "$(($last_line + 1)),$current_number_of_lines_in_log_file p" $log_file_path)
            send_content_to_api $api_path "text/plain" "$content"
            last_line=$current_number_of_lines_in_log_file
        fi
        sleep $log_sending_interval_in_seconds
    done
}

#--------------------------------------------------------------------------------

echo "Starting to stream logs"
stream_logs "jobs/$JOB_ID/system_logs" $SYSTEM_LOG_FILENAME &

#--------------------------------------------------------------------------------

echo "Job machine ready"
api_request "POST" "jobs/$JOB_ID/job_events" '{"type":"job_machine_ready"}'

#--------------------------------------------------------------------------------

echo "Cloning user repo"
clone_user_repo

cat <<EOF > ./job.rb
require "net/http"
require "uri"
require "json"
require "digest"

module SaturnCIAPI
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
        curl -f -u #{ENV["SATURNCI_API_USERNAME"]}:#{ENV["SATURNCI_API_PASSWORD"]} \
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
        curl -f -u #{ENV["SATURNCI_API_USERNAME"]}:#{ENV["SATURNCI_API_PASSWORD"]} \
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
  end
end

client = SaturnCIAPI::Client.new(ENV["HOST"])

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
File.open(ENV["TEST_OUTPUT_FILENAME"], 'w') {}

streaming_thread = Thread.new do
  last_line = 0

  while true
    current_number_of_lines_in_log_file = File.read(ENV["TEST_OUTPUT_FILENAME"]).lines.count

    if current_number_of_lines_in_log_file > last_line
      content = File.readlines(ENV["TEST_OUTPUT_FILENAME"])[last_line..-1].join

      test_output_request = SaturnCIAPI::FileContentRequest.new(
        host: ENV["HOST"],
        api_path: "jobs/#{ENV["JOB_ID"]}/test_output",
        content_type: "text/plain",
        file_path: ENV["TEST_OUTPUT_FILENAME"]
      )
      test_output_request.execute

      last_line = current_number_of_lines_in_log_file
    end

    sleep(1)
  end
end

puts "Running tests"
puts "jobs/#{ENV["JOB_ID"]}/test_suite_started"
client.post("jobs/#{ENV["JOB_ID"]}/job_events", type: "test_suite_started")

File.open('./example_status_persistence.rb', 'w') do |file|
  file.puts "RSpec.configure do |config|"
  file.puts "  config.example_status_persistence_file_path = '#{ENV['TEST_RESULTS_FILENAME']}'"
  file.puts "end"
end

test_files = Dir.glob('./spec/**/*_spec.rb')
chunks = test_files.each_slice((test_files.size / ENV['NUMBER_OF_CONCURRENT_JOBS'].to_i.to_f).ceil).to_a
selected_tests = chunks[ENV['JOB_ORDER_INDEX'].to_i - 1]
test_files_string = selected_tests.join(' ')

command = <<~COMMAND
script -c "sudo SATURN_TEST_APP_IMAGE_URL=#{registry_cache_image_url} docker-compose \
  -f .saturnci/docker-compose.yml run saturn_test_app \
  bundle exec rspec --require ./example_status_persistence.rb \
  --format=documentation --order rand:#{ENV["RSPEC_SEED"]} #{test_files_string}" \
  -f "#{ENV["TEST_OUTPUT_FILENAME"]}"
COMMAND

puts command

system(command)

# Without this sleep, there's a race condition between the
# test output stream finishing and the job_finished event
sleep(5)

puts "Job finished"
client.post("jobs/#{ENV["JOB_ID"]}/job_finished_events")

puts "Sending report"
test_reports_request = SaturnCIAPI::FileContentRequest.new(
  host: ENV["HOST"],
  api_path: "jobs/#{ENV["JOB_ID"]}/test_reports",
  content_type: "text/plain",
  file_path: ENV["TEST_RESULTS_FILENAME"]
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
EOF

ruby ./job.rb
