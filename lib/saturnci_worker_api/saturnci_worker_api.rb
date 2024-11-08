require "net/http"
require "uri"
require "json"
require "digest"
require "fileutils"
require "base64"
require "open3"

PROJECT_DIR = "/home/ubuntu/project"
TEST_OUTPUT_FILENAME = "tmp/test_output.txt"
TEST_RESULTS_FILENAME = "tmp/test_results.txt"

module SaturnCIWorkerAPI
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

  class TestSuiteCommand
    def initialize(registry_cache_image_url:, test_files_string:, rspec_seed:, test_output_filename:, docker_compose_env_vars:)
      @registry_cache_image_url = registry_cache_image_url
      @test_files_string = test_files_string
      @rspec_seed = rspec_seed
      @test_output_filename = test_output_filename
      @docker_compose_env_vars = docker_compose_env_vars
    end

    def to_s
      "script -f #{@test_output_filename} -c \"sudo #{script_env_vars} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose -f .saturnci/docker-compose.yml run #{docker_compose_env_vars} saturn_test_app #{rspec_command}"
    end

    private

    def script_env_vars
      "SATURN_TEST_APP_IMAGE_URL=#{@registry_cache_image_url}"
    end

    def docker_compose_env_vars
      @docker_compose_env_vars.map { |key, value| "-e #{key}=#{value}" }.join(" ")
    end

    def rspec_command
      "bundle exec rspec --require ./example_status_persistence.rb --format=documentation --order rand:#{@rspec_seed} #{@test_files_string}"
    end
  end
end
