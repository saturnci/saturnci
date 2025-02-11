require "net/http"
require "uri"

module SaturnCIRunnerAPI
  class FileContentRequest
    def initialize(host:, api_path:, content_type:, file_path:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @file_path = file_path
    end

    def execute
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = @content_type
      request.basic_auth(ENV["USER_ID"], ENV["USER_API_TOKEN"])
      request.body = File.read(@file_path)

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      puts response.body
      response
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end
end
