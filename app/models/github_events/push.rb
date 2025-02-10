module GitHubEvents
  class Push
    NUMBER_OF_TIMES_TO_REPEAT_BROADCAST = 20
    BROADCAST_INTERVAL_IN_SECONDS = 1

    def initialize(payload, github_repo_full_name)
      @payload = payload
      @github_repo_full_name = github_repo_full_name
    end

    def process
      Project.where(github_repo_full_name: @github_repo_full_name).each do |project|
        build = Build.new(project:)
        build.assign_attributes(build_specification)
        prepare_build(build)
      end
    end

    def build_specification
      ref_path = @payload["ref"]
      head_commit = @payload["head_commit"]

      {
        branch_name: ref_path.split("/").last,
        author_name: head_commit["author"]["name"],
        commit_hash: head_commit["id"],
        commit_message: head_commit["message"]
      }
    end

    def prepare_build(build)
      if build.project.start_builds_automatically_on_git_push
        build.start!
      else
        build.save!
      end

      broadcast_build(build)
    end

    def broadcast_build(build)
      NUMBER_OF_TIMES_TO_REPEAT_BROADCAST.times do
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
