require "json"
require_relative "api_request"
require_relative "display/output_table"

module SaturnCICLI
  class Client
    DEFAULT_HOST = "http://localhost:3000"
    attr_reader :host, :username, :password

    def initialize(username:, password:, host: DEFAULT_HOST)
      @username = username
      @password = password
      @host = host
      request("builds")
    end

    def builds(options = {})
      response = request("builds")
      builds = JSON.parse(response.body)
      puts Display::OutputTable.new(builds, options).to_s
    end

    private

    def request(endpoint)
      APIRequest.new(self, endpoint).response
    end
  end
end
