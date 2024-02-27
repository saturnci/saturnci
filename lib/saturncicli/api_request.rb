require "net/http"
require "uri"

module SaturnCICLI
  class APIRequest
    def initialize(client, endpoint)
      @client = client
      @endpoint = endpoint
    end

    def response
      send_request.tap do |response|
        raise "Bad credentials." if response.code != "200"
      end
    end

    private

    def send_request
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
    end

    def request
      Net::HTTP::Get.new(uri).tap do |request|
        request.basic_auth @client.username, @client.password
      end
    end

    def uri
      URI("#{@client.host}/api/v1/#{@endpoint}")
    end
  end
end
