require "net/http"
require "uri"

module SaturnCICLI
  class APIRequest
    def initialize(credential:, method:, endpoint:, body: {})
      @credential = credential
      @method = method
      @endpoint = endpoint
      @body = body
    end

    def response
      send_request.tap do |response|
        raise "Bad credentials." if response.code == "401"
      end
    end

    def use_ssl?
      uri.scheme == "https"
    end

    private

    def send_request
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: use_ssl?) do |http|
        http.request(request)
      end
    end

    def request
      method.new(uri).tap do |request|
        request.basic_auth @credential.user_id, @credential.api_token
        request.content_type = "application/json"
        request.body = @body.to_json
      end
    end

    def method
      case @method
      when "GET"
        Net::HTTP::Get
      when "PATCH"
        Net::HTTP::Patch
      end
    end

    def uri
      URI("#{@credential.host}/api/v1/#{@endpoint}")
    end
  end
end
