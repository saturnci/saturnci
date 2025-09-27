module SaturnCICLI
  class Arguments
    def initialize(argv)
      @argv = argv
    end

    def command
      case @argv[0]
      when "test-runners"
        case @argv[1]
        when nil
          [:test_runners]
        when "delete"
          if @argv[2] == "--all"
            [:delete_all_test_runners]
          else
            test_runner_ids = @argv[2..-1]
            [:delete_test_runner, test_runner_ids]
          end
        when "ssh"
          test_runner_id = @argv[2]
          [:ssh_by_test_runner_id, test_runner_id]
        end
      when "runs"
        [:runs]
      when "run"
        run_id = @argv[1]
        [:run, run_id]
      when "test-suite-runs"
        [:test_suite_runs]
      when nil
        [:test_runners]
      else
        fail "Unknown argument \"#{@argv.join(" ")}\""
      end
    end
  end
end
