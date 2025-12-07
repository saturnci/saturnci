module GitHubEvents
  class Push
    def initialize(payload, github_repo_full_name)
      @payload = payload
      @github_repo_full_name = github_repo_full_name
    end

    def process
      Repository.where(github_repo_full_name: @github_repo_full_name).each do |repository|
        test_suite_run = TestSuiteRun.new(repository:)
        test_suite_run.assign_attributes(test_suite_run_specification)
        prepare_test_suite_run(test_suite_run)
      end
    end

    def test_suite_run_specification
      ref_path = @payload["ref"]
      head_commit = @payload["head_commit"]

      {
        branch_name: ref_path.split("/").last,
        author_name: head_commit["author"]["name"],
        commit_hash: head_commit["id"],
        commit_message: head_commit["message"]
      }
    end

    def prepare_test_suite_run(test_suite_run)
      if test_suite_run.repository.start_test_suite_runs_automatically_on_git_push
        test_suite_run.start!
      else
        test_suite_run.save!
      end

      test_suite_run.broadcast
    end
  end
end
