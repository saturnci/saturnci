module GitHubEvents
  class Push
    def initialize(payload, github_repo_full_name)
      @payload = payload
      @github_repo_full_name = github_repo_full_name
    end

    def process
      Project.where(github_repo_full_name: @github_repo_full_name).each do |project|
        prepare_build(Build.new(project:))
      end
    end

    def prepare_build(build)
      ref_path = @payload["ref"]
      head_commit = @payload["head_commit"]

      build.branch_name = ref_path.split("/").last
      build.author_name = head_commit["author"]["name"]
      build.commit_hash = head_commit["id"]
      build.commit_message = head_commit["message"]

      if build.project.start_builds_automatically_on_git_push
        build.start!
      else
        build.save!
      end

      build.broadcast
    end
  end
end
