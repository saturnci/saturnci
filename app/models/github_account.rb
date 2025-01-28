require "octokit"

# A GitHubAccount is created via a GitHub "created" webhook
# event, which is handled in an object called GitHub::Installation.
class GitHubAccount < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  has_many :projects, dependent: :destroy

  def octokit_client
    Octokit::Client.new(bearer_token: GitHubJWTToken.generate)
  end

  def installation_access_octokit_client
    Octokit::Client.new(bearer_token: GitHubToken.token(github_installation_id))
  end
end
