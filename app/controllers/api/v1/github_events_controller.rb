module API
  module V1
    class GitHubEventsController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!

      def create
        payload_raw = request.body.read
        payload = JSON.parse(payload_raw)
        Rails.logger.info "GitHub webhook payload: #{payload.inspect}"

        GitHubEvent.create!(body: payload)

        case payload["action"]
        when "created"
          handle_installation_event(payload)
        else
          handle_push_event(payload)
        end

        head :ok
      end

      private

      def handle_installation_event(payload)
        if payload["installation"]["account"]["type"] == "Organization"
          github_account_id = payload["sender"]["id"]
        else
          github_account_id = payload["installation"]["account"]["id"]
        end

        user = User.find_by!(uid: github_account_id, provider: "github")

        user.saturn_installations.create!(
          github_installation_id: payload["installation"]["id"],
          name: payload["installation"]["account"]["login"],
        )
      end

      def handle_push_event(payload)
        repo_full_name = params[:repository][:full_name]
        ref_path = payload["ref"]
        head_commit = payload["head_commit"]

        Project.where(github_repo_full_name: repo_full_name).each do |project|
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
end
