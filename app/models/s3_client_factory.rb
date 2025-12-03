require "aws-sdk-s3"

class S3ClientFactory
  def self.client
    Aws::S3::Client.new(
      endpoint: "https://nyc3.digitaloceanspaces.com",
      access_key_id: ENV["DIGITALOCEAN_SPACES_ACCESS_KEY_ID"],
      secret_access_key: ENV["DIGITALOCEAN_SPACES_SECRET_ACCESS_KEY"],
      region: "us-east-1",
      ssl_verify_peer: Rails.configuration.s3_ssl_verify_peer
    )
  end
end
