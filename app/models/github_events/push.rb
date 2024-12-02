module GitHubEvents
  class Push
    NUMBER_IF_TIMES_TO_REPEAT_BROADCAST = 20
    BROADCAST_INTERVAL_IN_SECONDS = 1

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

      broadcast_build(build)
    end

    def broadcast_build(build)
      NUMBER_IF_TIMES_TO_REPEAT_BROADCAST.times do
        sleep(BROADCAST_INTERVAL_IN_SECONDS)

        if build.status == "Running"
          sleep(1)
          build.broadcast
          break
        end
      end
    end
  end
end
