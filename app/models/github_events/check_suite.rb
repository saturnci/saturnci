module GitHubEvents
  class CheckSuite
    def initialize(payload)
      @payload = payload
      @check_suite = @payload["check_suite"]
      @github_repo_full_name = payload["repository"]["full_name"]
    end

    def process
      project = Project.find_by(github_repo_full_name: @github_repo_full_name)
      build = Build.new(project:)
      build.assign_attributes(build_specification)
      build.save!
    end

    def build_specification
      {
        branch_name: @check_suite["head_branch"],
        author_name: @check_suite["head_commit"]["author"]["name"],
        commit_hash: @check_suite["head_sha"],
        commit_message: @check_suite["head_commit"]["message"]
      }
    end
  end
end
