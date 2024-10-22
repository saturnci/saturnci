# frozen_string_literal: true

require 'jwt'
require 'octokit'

class GitHubToken
  def self.generate(installation_id)
    fail 'Installation ID is missing' if installation_id.blank?

    token(installation_id)
  end

  def self.token(installation_id)
    # GITHUB_PRIVATE_PEM comes from the private key which can be generated at
    # https://github.com/settings/apps/saturnci-development and
    # https://github.com/settings/apps/saturnci
    private_pem = Rails.configuration.github_private_pem
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      iat: Time.now.to_i, # Issued-at time
      exp: Time.now.to_i + (10 * 60), # JWT expiration time
      iss: ENV.fetch('GITHUB_APP_ID', nil)
    }

    jwt = JWT.encode(payload, private_key, 'RS256')
    client = Octokit::Client.new(bearer_token: jwt)
    installation_token = client.create_app_installation_access_token(installation_id)
    installation_token[:token]
  end
end
