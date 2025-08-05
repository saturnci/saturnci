class GitHubClient
  def initialize(github_oauth_token)
    @github_oauth_token = github_oauth_token
  end

  def octokit_client
    @octokit_client ||= Octokit::Client.new(access_token: @github_oauth_token)
  end

  def repositories
    Rails.cache.fetch("user/#{id}/github_repositories", expires_in: 1.week) do
      repositories = octokit_client.repositories

      loop do
        break if octokit_client.last_response.rels[:next].nil?
        repositories.concat octokit_client.get(octokit_client.last_response.rels[:next].href)
      end

      Repository.where(github_repo_full_name: repositories.map(&:full_name))
    end
  end
end
