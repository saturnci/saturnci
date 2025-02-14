module GitHubEvents
  class PullRequest
    def initialize(payload)
      @payload = payload
      @github_repo_full_name = payload["repository"]["full_name"]
    end

    def process
      return unless @payload["action"] == "opened"
      
      project = Project.find_by(github_repo_full_name: @github_repo_full_name)
      return unless project
      
      build = Build.new(project: project)
      build.assign_attributes(build_specification)
      build.start!
      GitHubCheckRun.new(build:).start!
    end

    def build_specification
      pull_request = @payload["pull_request"]
      head = pull_request["head"]
      user = pull_request["user"]
      
      {
        branch_name: head["ref"],
        commit_hash: head["sha"],
        commit_message: pull_request["title"],
        author_name: user["login"]
      }
    end
  end
end
