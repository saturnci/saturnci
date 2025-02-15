module API
  module V1
    class GitHubEventsController < API::V1::APIController
      skip_before_action :authenticate_api_user!

      def create
        payload_raw = request.body.read
        payload = JSON.parse(payload_raw)
        Rails.logger.info "GitHub webhook payload: #{payload.inspect}"

        GitHubEvent.create!(body: payload)

        case request.headers["X-GitHub-Event"]
        when "created"
          GitHubEvents::Installation.new(payload).process
        when "push"
          GitHubEvents::Push.new(payload, params[:repository][:full_name]).process
        when "pull_request"
          GitHubEvents::PullRequest.new(payload).process
        end

        skip_authorization
        head :ok
      end
    end
  end
end
