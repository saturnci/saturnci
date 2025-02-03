require "net/http"
require "uri"

module SaturnCICLI
  class APIRequest
    def initialize(client, request_method, endpoint, body = nil)
      @client = client
      @request_method = request_method
      @endpoint = endpoint
      @body = body
    end

    def response
      send_request.tap do |response|
        raise "Bad credentials." if response.code == "401"
      end
    end

    private

    def send_request
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def request
      request_method.new(uri).tap do |request|
        request.basic_auth @client.username, @client.password
        request.content_type = "application/json"
        request.body = @body.to_json
      end
    end

    def request_method
      case @request_method
      when "GET"
        Net::HTTP::Get
      when "PATCH"
        Net::HTTP::Patch
      end
    end

    def uri
      URI("#{@client.host}/api/v1/#{@endpoint}")
    end
  end
end
