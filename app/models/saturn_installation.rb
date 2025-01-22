# A SaturnInstallation is created via a GitHub "created" webhook
# event, which is handled in an object called GitHub::Installation.
class SaturnInstallation < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  has_many :projects, dependent: :destroy

  def octokit_client
    bearer_token = GitHubToken.generate(github_installation_id)
    Octokit::Client.new(bearer_token: bearer_token)
  end
end
