require "base64"
require "tempfile"

module SaturnCICLI
  class ConnectionDetails
    WAIT_INTERVAL_IN_SECONDS = 5

    def initialize(request:)
      @request = request
    end

    def refresh
      response = @request.call

      if response.code != "200"
        puts JSON.parse(response.body)
        exit
      end

      @run = JSON.parse(response.body)
      self
    end

    def ip_address
      @run["ip_address"]
    end

    def rsa_key_path
      tempfile = Tempfile.new("rsa_key")
      tempfile.write(rsa_key)
      tempfile.close

      tempfile.path
    end

    private

    def rsa_key
      Base64.decode64(@run["rsa_key"])
    end
  end
end
