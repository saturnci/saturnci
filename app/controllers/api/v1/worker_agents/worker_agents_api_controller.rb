module API
  module V1
    module WorkerAgents
      class WorkerAgentsAPIController < ActionController::Base
        skip_before_action :verify_authenticity_token
        before_action :authenticate_test_runner!

        def authenticate_test_runner!
          authenticate_or_request_with_http_basic do |test_runner_id, api_token|
            access_token = AccessToken.find_by(value: api_token)
            @current_test_runner = TestRunner.find_by(id: test_runner_id, access_token: access_token) if access_token.present?
            @current_test_runner.present?
          end
        end
      end
    end
  end
end
