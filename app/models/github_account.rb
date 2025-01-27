require 'jwt'
require 'octokit'

# A GitHubAccount is created via a GitHub "created" webhook
# event, which is handled in an object called GitHub::Installation.
class GitHubAccount < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  has_many :projects, dependent: :destroy

  def octokit_client
    private_pem = Rails.configuration.github_private_pem
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      iat: Time.now.to_i,  # Issued at time
      exp: Time.now.to_i + (10 * 60),  # JWT expiration time (10 minutes)
      iss: ENV['GITHUB_APP_ID']
    }

    jwt = JWT.encode(payload, private_key, 'RS256')
    Octokit::Client.new(bearer_token: jwt)
  end
end
