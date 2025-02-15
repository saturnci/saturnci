module API
  module V1
    class GitHubTokensController < APIController
      def create
        skip_authorization
        render plain: GitHubToken.generate(params[:github_installation_id])
      end
    end
  end
end
