# frozen_string_literal: true

require 'jwt'
require 'octokit'

# Maybe this should be called GitHubInstallationAccessToken
class GitHubToken
  def self.generate(github_installation_id)
    fail 'Installation ID is missing' if github_installation_id.blank?

    token(github_installation_id)
  end

  def self.token(github_installation_id)
    client = Octokit::Client.new(bearer_token: GitHubJWTToken.generate)
    client.create_app_installation_access_token(github_installation_id)[:token]
  end
end
