module API
  module V1
    class GitHubTokensController < APIController
      def create
        render plain: GitHubToken.generate(params[:github_installation_id])
      end
    end
  end
end
