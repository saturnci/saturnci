module API
  module V1
    class GitHubEventsController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!

      def create
        skip_authorization

        payload_raw = request.body.read
        payload = JSON.parse(payload_raw)
        Rails.logger.info "GitHub webhook payload: #{payload.inspect}"

        GitHubEvent.create!(body: payload)

        case payload["action"]
        when "created"
          GitHubEvents::Installation.new(payload).process
        else
          GitHubEvents::Push.new(payload, params[:repository][:full_name]).process
        end

        head :ok
      end
    end
  end
end
