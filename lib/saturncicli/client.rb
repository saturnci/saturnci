require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"
require_relative "connection_details"

module SaturnCICLI
  class Client
    def initialize(credential)
      @credential = credential
    end

    def execute(argument)
      case argument
      when /--run\s+(\S+)/
        run_id = argument.split(" ")[1]

        connection_details = ConnectionDetails.new(
          request: -> { get("runs/#{run_id}") }
        )

        ssh(run_id, connection_details)
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
      response = get("builds")

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
      response = get("runs")
      runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :run,
        items: runs[0..19],
        options: options
      )
    end

    def run(run_id)
      response = get("runs/#{run_id}")
      run_attrs = JSON.parse(response.body)

      run_attrs.each do |key, value|
        puts "#{key}: #{value}"
      end
    end

    def ssh(run_id, connection_details)
      until connection_details.refresh.ip_address
        puts "Waiting for IP address..."
        sleep(ConnectionDetails::WAIT_INTERVAL_IN_SECONDS)
      end

      until connection_details.refresh.rsa_key_path
        puts "Waiting for RSA key..."
        sleep(ConnectionDetails::WAIT_INTERVAL_IN_SECONDS)
      end

      ssh_session = SSHSession.new(
        ip_address: connection_details.ip_address,
        rsa_key_path: connection_details.rsa_key_path
      )

      response = patch("runs/#{run_id}", { "terminate_on_completion" => false })
      raise "Problem: #{response.inspect}" unless response.code == "200"
      puts ssh_session.command
      ssh_session.connect
    end

    private

    def get(endpoint)
      APIRequest.new(
        credential: @credential,
        method: "GET",
        endpoint:
      ).response
    end

    def patch(endpoint, body)
      APIRequest.new(
        credential: @credential,
        method: "PATCH",
        endpoint:,
        body:
      ).response
    end
  end
end
