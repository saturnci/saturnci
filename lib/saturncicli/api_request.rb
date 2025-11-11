require "net/http"
require "uri"

module SaturnCICLI
  class APIRequest
    def initialize(credential:, method:, endpoint:, body: {}, debug: false)
      @credential = credential
      @method = method
      @endpoint = endpoint
      @body = body
      @debug = debug
    end

    def response
      if @debug
        puts "Request details:"
        puts uri.scheme
        puts uri.hostname
        puts uri.path
        puts uri.port
        puts
      end

      http_client.start do
        http_client.request(request)
      end.tap do |response|
        if @debug
          puts "Response:"
          puts "#{response.code} #{response.message}"
          puts response.body
        end
      end
    end

    def use_ssl?
      uri.scheme == "https"
    end

    private

    def http_client
      Net::HTTP.new(uri.hostname, uri.port).tap do |c|
        c.use_ssl = use_ssl?

        # Without this cert_store stuff, we get:
        # certificate verify failed (unable to get local issuer certificate)
        # (OpenSSL::SSL::SSLError)
        c.cert_store = OpenSSL::X509::Store.new
        c.cert_store.set_default_paths
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
      when "DELETE"
        Net::HTTP::Delete
      end
    end

    def uri
      URI("#{@credential.host}/api/v1/#{@endpoint}")
    end
  end
end
