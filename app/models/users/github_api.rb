module Users
  module GitHubAPI
    extend ActiveSupport::Concern

    included do
      has_many :github_accounts
      has_many :github_oauth_tokens
    end

    def can_hit_github_api?
      Rails.cache.fetch("user/#{id}/can_hit_github_api", expires_in: 1.hour) do
        octokit_client.user
      end

      true
    rescue Octokit::Unauthorized
      Rails.cache.delete("user/#{id}/can_hit_github_api")
      false
    end

    def can_access_repository?(repository)
      github_repositories.pluck(:id).include?(repository.id)
    end

    def octokit_client
      @octokit_client ||= Octokit::Client.new(access_token: github_oauth_token)
    end

    def github_oauth_token
      github_oauth_tokens.order(created_at: :desc).first&.value
    end

    def github_repositories
      GitHubClient.new(self).repositories
    end
  end
end
