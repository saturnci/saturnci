module SaturnCICLI
  class ConnectionDetails
    WAIT_INTERVAL_IN_SECONDS = 5

    def initialize(request:)
      @request = request
    end

    def refresh
      response = @request.call
      @run = JSON.parse(response.body)
      self
    end

    def ip_address
      @run["ip_address"]
    end

    def rsa_key_path
      @run["runner_rsa_key_path"]
    end
  end
end
