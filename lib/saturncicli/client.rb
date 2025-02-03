# frozen_string_literal: true

require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"
require_relative "connection_details"

module SaturnCICLI
  class Client
    DEFAULT_HOST = "https://app.saturnci.com"
    attr_reader :host, :username, :password

    def initialize(username:, password:, host: DEFAULT_HOST)
      @username = username
      @password = password
      @host = host
    end

    def execute(argument)
      case argument
      when /--run\s+(\S+)/
        run_id = argument.split(" ")[1]

        connection_details = ConnectionDetails.new(
          request: -> { request("runs/#{run_id}") }
        )

        ssh(run_id)
      when "runs"
        runs
      when /run\s+/
        run_id = argument.split(" ")[1]
        run(run_id)
      when "builds"
        builds
      when nil
        builds
      else
        fail "Unknown argument \"#{argument}\""
      end
    end

    def builds(options = {})
      response = request("builds")

      if response.code == "500"
        puts "500 Internal Server Error"
        return
      end

      builds = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :build,
        items: builds,
        options: options
      )
    end

    def runs(options = {})
      response = request("runs")
      runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :run,
        items: runs,
        options: options
      )
    end

    def run(run_id)
      response = request("runs/#{run_id}")
      run_attrs = JSON.parse(response.body)

      run_attrs.each do |key, value|
        puts "#{key}: #{value}"
      end
    end

    def ssh(run_id, connection_details)
      until connection_details.refresh.ip_address
        print "."
        sleep(ConnectionDetails::WAIT_INTERVAL_IN_SECONDS)
      end

      ssh_session = SSHSession.new(
        ip_address: connection_details.ip_address,
        rsa_key_path: connection_details.rsa_key_path
      )

      ssh_session.connect
      puts ssh_session.command
    end

    private

    def request(endpoint)
      APIRequest.new(self, endpoint).response
    end
  end
end
