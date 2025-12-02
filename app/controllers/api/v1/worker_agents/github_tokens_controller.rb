module API
  module V1
    module WorkerAgents
      class GitHubTokensController < WorkerAgentsAPIController
        def create
          render plain: GitHubToken.generate(params[:github_installation_id])
        end
      end
    end
  end
end
