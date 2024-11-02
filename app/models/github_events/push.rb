module GitHubEvents
  class Push
    def initialize(payload, github_repo_full_name)
      @payload = payload
      @github_repo_full_name = github_repo_full_name
    end

    def process
      ref_path = @payload["ref"]
      head_commit = @payload["head_commit"]

      Project.where(github_repo_full_name: @github_repo_full_name).each do |project|
        build = Build.new(project: project)
        build.branch_name = ref_path.split("/").last
        build.author_name = head_commit["author"]["name"]
        build.commit_hash = head_commit["id"]
        build.commit_message = head_commit["message"]
        build.start!
      end
    end
  end
end
