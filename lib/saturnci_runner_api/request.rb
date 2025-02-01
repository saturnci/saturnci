require "net/http"

module SaturnCIRunnerAPI
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

      r.basic_auth(ENV["USER_ID"], ENV["USER_API_TOKEN"])
      r["Content-Type"] = "application/json"
      r.body = @payload.to_json if @payload
      r
    end

    private

    def url
      URI("#{@host}/api/v1/#{@endpoint}")
    end
  end
end
