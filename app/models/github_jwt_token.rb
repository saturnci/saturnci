require "jwt"

class GitHubJWTToken
  def self.generate
    # The private pem comes from the private key which can be generated at
    # https://github.com/settings/apps/saturnci-development,
    # https://github.com/settings/apps/saturnci-staging and
    # https://github.com/settings/apps/saturnci (production)
    private_pem = Rails.configuration.github_private_pem
    private_key = OpenSSL::PKey::RSA.new(private_pem)

    payload = {
      # The time the token was issued
      iat: Time.now.to_i,

      # Token expiration time
      exp: Time.now.to_i + (10 * 60),

      # Issuer, i.e. the SaturnCI app
      iss: ENV["GITHUB_APP_ID"]
    }

    JWT.encode(payload, private_key, "RS256")
  end
end
