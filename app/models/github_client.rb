class GitHubClient
  def initialize(user)
    @user = user
  end

  def octokit_client
    @octokit_client ||= Octokit::Client.new(access_token: @user.github_oauth_token)
  end

  def repositories
    if @user.impersonating?
      @repositories = Repository.joins(:github_account)
        .where(github_accounts: { user_id: @user.id })
    else
      Rails.cache.fetch(cache_key, expires_in: 1.week) do
        Repository.where(github_repo_full_name: octokit_repositories.map(&:full_name))
      end
    end
  end

  def invalidate_repositories_cache
    Rails.cache.delete(cache_key)
  end

  private

  def octokit_repositories
    repositories = octokit_client.repositories
    return [] if repositories.nil?

    loop do
      break if octokit_client.last_response.rels[:next].nil?
      repositories.concat octokit_client.get(octokit_client.last_response.rels[:next].href)
    end

    return repositories
  rescue Octokit::Unauthorized
    raise GitHubTokenExpiredError, "GitHub token has expired"
  end

  def cache_key
    "user/#{@user.id}/github_repositories"
  end
end
