module SaturnCICLI
  class Arguments
    def initialize(argv)
      @params = argv.join(" ")
    end

    def command
      case @params
      when /--test-runner\s+(\S+)/
        test_runner_id = @params.split(" ")[1]
        [:ssh_by_test_runner_id, test_runner_id]
      when "runs"
        [:runs]
      when /run\s+/
        run_id = @params.split(" ")[1]
        [:run, run_id]
      when "test-runners"
        [:test_runners]
      when "test-suite-runs"
        [:test_suite_runs]
      when nil
        [:test_runners]
      else
        fail "Unknown argument \"#{@params}\""
      end
    end
  end
end
