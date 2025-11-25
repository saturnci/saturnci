module API
  module V1
    module TestRunnerAgents
      class GitHubTokensController < TestRunnerAgentsAPIController
        def create
          skip_authorization
          render plain: GitHubToken.generate(params[:github_installation_id])
        end
      end
    end
  end
end
