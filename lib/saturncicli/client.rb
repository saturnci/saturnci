require "json"
require_relative "api_request"
require_relative "display/output_table"

module SaturnCICLI
  class Client
    DEFAULT_HOST = "http://localhost:3000"
    DEFAULT_NUMBER_OF_BUILDS_TO_SHOW = 10
    attr_reader :host, :username, :password

    def initialize(username:, password:, host: DEFAULT_HOST)
      @username = username
      @password = password
      @host = host
      request("builds")
    end

    def builds
      response = request("builds")
      builds = JSON.parse(response.body)[0..DEFAULT_NUMBER_OF_BUILDS_TO_SHOW]
      puts Display::OutputTable.new(builds).to_s
    end

    private

    def request(endpoint)
      APIRequest.new(self, endpoint).response
    end
  end
end
