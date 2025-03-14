require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"
require_relative "connection_details"

module SaturnCICLI
  class Client
    DEFAULT_LIMIT = 20

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
      when /--test-runner\s+(\S+)/
        test_runner_id = argument.split(" ")[1]

        connection_details = ConnectionDetails.new(
          request: -> { get("test_runners/#{test_runner_id}") }
        )

        ssh(test_runner_id, connection_details)
      when "runs"
        runs
      when /run\s+/
        run_id = argument.split(" ")[1]
        run(run_id)
      when "test-runners"
        test_runners
      when "test-suite-runs"
        test_suite_runs
      when nil
        test_suite_runs
      else
        fail "Unknown argument \"#{argument}\""
      end
    end

    def test_runners
      response = get("test_runners")

      if response.code != "200"
        puts "Request failed"
        puts response.inspect
        return
      end

      test_runners = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :test_runner,
        items: test_runners[0..DEFAULT_LIMIT-1],
      )
    end

    def test_suite_runs(options = {})
      response = get("test_suite_runs")

      if response.code == "500"
        puts "500 Internal Server Error"
        return
      end

      test_suite_runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :test_suite_run,
        items: test_suite_runs[0..DEFAULT_LIMIT-1],
        options: options
      )
    end

    def runs(options = {})
      response = get("runs")
      runs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :run,
        items: runs[0..DEFAULT_LIMIT-1],
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

    def ssh(test_runner_id, connection_details)
      until connection_details.refresh.ip_address
        puts "Waiting for IP address..."
        sleep(ConnectionDetails::WAIT_INTERVAL_IN_SECONDS)
      end

      ssh_session = SSHSession.new(
        ip_address: connection_details.ip_address,
        rsa_key_path: connection_details.rsa_key_path
      )

      response = patch("test_runners/#{test_runner_id}", { "terminate_on_completion" => false })
      raise "Problem: #{response.inspect}" unless response.code == "200"
      puts ssh_session.command
      ssh_session.connect
    end

    private

    def get(endpoint)
      APIRequest.new(
        credential: @credential,
        method: "GET",
        endpoint:,
        debug: ENV["DEBUG"]
      ).response
    end

    def patch(endpoint, body)
      APIRequest.new(
        credential: @credential,
        method: "PATCH",
        endpoint:,
        body:,
        debug: ENV["DEBUG"]
      ).response
    end
  end
end
