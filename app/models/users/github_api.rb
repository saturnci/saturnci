module Users
  module GitHubAPI
    extend ActiveSupport::Concern

    included do
      has_many :github_accounts
      has_many :github_oauth_tokens
    end

    def can_hit_github_api?
      Rails.cache.fetch("user/#{id}/can_hit_github_api", expires_in: 1.hour) do
        github_client.user
      end

      true
    rescue Octokit::Unauthorized
      false
    end

    def can_access_repository?(repository)
      github_repositories.map(&:id).include?(repository.id)
    end

    def github_client
      @github_client ||= Octokit::Client.new(access_token: github_oauth_token)
    end

    def github_oauth_token
      github_oauth_tokens.order(created_at: :desc).first&.value
    end

    def github_repositories
      Rails.cache.fetch("user/#{id}/github_repositories", expires_in: 1.week) do
        repositories = github_client.repositories

        loop do
          break if github_client.last_response.rels[:next].nil?
          repositories.concat github_client.get(github_client.last_response.rels[:next].href)
        end

        Repository.where(github_repo_full_name: repositories.map(&:full_name))
      end
    end
  end
end
