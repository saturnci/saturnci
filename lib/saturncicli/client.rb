require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"
require_relative "test_runner"

module SaturnCICLI
  class Client
    DEFAULT_LIMIT = 30

    def initialize(credential)
      @credential = credential
    end

    def execute(command)
      send(*command)
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

    def delete_test_runner(test_runner_ids)
      test_runner_ids.each do |test_runner_id|
        response = delete("test_runners/#{test_runner_id}")
        puts response.inspect
      end
    end

    def delete_all_test_runners
      response = delete("test_runner_collection")
      puts response.inspect
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

    def ssh_by_test_runner_id(test_runner_id)
      test_runner = TestRunner.new(
        id: test_runner_id,
        readiness_check_request: -> { get("test_runners/#{test_runner_id}") }
      )

      ssh(test_runner)
    end

    def ssh(test_runner)
      until test_runner.refresh.ip_address
        puts "Waiting for IP address..."
        sleep(TestRunner::WAIT_INTERVAL_IN_SECONDS)
      end

      ssh_session = SSHSession.new(
        ip_address: test_runner.ip_address,
        rsa_key_path: test_runner.rsa_key_path
      )

      response = patch("test_runners/#{test_runner.id}", { "terminate_on_completion" => false })
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

    def delete(endpoint)
      APIRequest.new(
        credential: @credential,
        method: "DELETE",
        endpoint:,
        debug: ENV["DEBUG"]
      ).response
    end
  end
end
