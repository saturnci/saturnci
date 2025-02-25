module API
  module V1
    class GitHubEventsController < API::V1::APIController
      skip_before_action :authenticate_api_user!

      def create
        payload_raw = request.body.read
        payload = JSON.parse(payload_raw)
        Rails.logger.info "GitHub webhook payload: #{payload.inspect}"

        github_event = GitHubEvent.create!(
          body: payload,
          type: request.headers["X-GitHub-Event"]
        )

        Rails.logger.info "Event type: #{github_event.type}"

        case github_event.type
        when "installation"
          GitHubEvents::Installation.new(payload).process
        when "push"
          GitHubEvents::Push.new(payload, params[:repository][:full_name]).process
        when "pull_request"
          GitHubEvents::PullRequest.new(payload).process
        else
          github_event.update!(type: "#{github_event.type} (not processed)")
        end

        Rails.logger.info "Finished processing GitHub webhook"
        skip_authorization
        head :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
