module SaturnCICLI
  class Arguments
    def initialize(argv)
      @argv = argv
      @params = argv.join(" ")
    end

    def command
      case @argv[0]
      when "--test-runner"
        test_runner_id = @argv[1]

        case @argv[2]
        when "delete"
          [:delete_test_runner, test_runner_id]
        when "ssh"
          [:ssh_by_test_runner_id, test_runner_id]
        end
      when "runs"
        [:runs]
      when "--run"
        run_id = @argv[1]
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
