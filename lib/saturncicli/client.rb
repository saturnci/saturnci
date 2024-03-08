require "json"
require_relative "api_request"
require_relative "display/table"
require_relative "ssh_session"

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

    def execute(argument)
      case argument
      when /--job\s+(\S+)/
        job_id = argument.split(" ")[1]
        ssh(job_id)
      when "jobs"
        jobs
      when "builds"
        builds
      when nil
        builds
      else
        raise "Unknown argument \"#{argument}\""
      end
    end

    def builds(options = {})
      response = request("builds")
      builds = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :build,
        items: builds,
        options: options
      )
    end

    def jobs(options = {})
      response = request("jobs")
      jobs = JSON.parse(response.body)

      puts Display::Table.new(
        resource_name: :job,
        items: jobs,
        options: options
      )
    end

    def ssh(job_id)
      response = request("jobs/#{job_id}")
      job = JSON.parse(response.body)

      while job["ip_address"].nil? do
        print "."
        sleep(5)
        response = request("jobs/#{job_id}")
        job = JSON.parse(response.body)
      end

      ssh_session = SSHSession.new(job["ip_address"], job["job_machine_rsa_key_path"])
      ssh_session.connect
      puts ssh_session.command
    end

    private

    def request(endpoint)
      APIRequest.new(self, endpoint).response
    end
  end
end
