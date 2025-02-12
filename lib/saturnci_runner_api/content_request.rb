require "net/http"
require "uri"

module SaturnCIRunnerAPI
  class ContentRequest
    def initialize(host:, api_path:, content_type:, content:)
      @host = host
      @api_path = api_path
      @content_type = content_type
      @content = content
    end

    def execute
      uri = URI(url)
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(ENV["USER_ID"], ENV["USER_API_TOKEN"])
      request["Content-Type"] = @content_type
      request.body = @content

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end
    end

    private

    def url
      "#{@host}/api/v1/#{@api_path}"
    end
  end
end
