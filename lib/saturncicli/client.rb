# frozen_string_literal: true

require 'json'
require_relative 'api_request'
require_relative 'display/table'
require_relative 'ssh_session'
require_relative 'connection_details'

module SaturnCICLI
  class Client
    DEFAULT_HOST = 'http://localhost:3000'
    attr_reader :host, :username, :password

    def initialize(username:, password:, host: DEFAULT_HOST)
      @username = username
      @password = password
      @host = host
      request('builds')
    end

    def execute(argument)
      case argument
      when /--job\s+(\S+)/
        job_id = argument.split(' ')[1]
        ssh(job_id)
      when 'jobs'
        jobs
      when 'builds'
        builds
      when nil
        builds
      else
        fail "Unknown argument \"#{argument}\""
      end
    end

    def builds(options = {})
      response = request('builds')
      builds = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :build,
        items: builds,
        options: options
      )
    end

    def jobs(options = {})
      response = request('jobs')
      jobs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :job,
        items: jobs,
        options: options
      )
    end

    def ssh(job_id)
      connection_details = ConnectionDetails.new(
        request: -> { request("jobs/#{job_id}") }
      )

      until connection_details.refresh.ip_address
        print '.'
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
