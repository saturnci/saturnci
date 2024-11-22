module SaturnCIRunnerAPI
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
end
