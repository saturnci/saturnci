module API
  module V1
    class GitHubEventsController < API::V1::APIController
      skip_before_action :authenticate_api_user!

      def create
        payload_raw = request.body.read
        payload = JSON.parse(payload_raw)
        Rails.logger.info "GitHub webhook payload: #{payload.inspect}"

        project = Project.find_by(
          github_repo_full_name: payload["repository"]["full_name"]
        )

        GitHubEvent.create!(project:, body: payload)

        case payload["action"]
        when "created"
          GitHubEvents::Installation.new(payload).process
        when "push"
          GitHubEvents::Push.new(payload, params[:repository][:full_name]).process
        end

        head :ok
      end
    end
  end
end
