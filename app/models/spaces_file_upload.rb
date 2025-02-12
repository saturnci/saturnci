class SpacesFileUpload
  def initialize(filename:, body:, content_type:)
    @filename = filename
    @body = body
    @content_type = content_type

    @s3_client = Aws::S3::Client.new(
      endpoint: "https://nyc3.digitaloceanspaces.com",
      access_key_id: ENV["DIGITALOCEAN_SPACES_ACCESS_KEY_ID"],
      secret_access_key: ENV["DIGITALOCEAN_SPACES_SECRET_ACCESS_KEY"],
      region: "us-east-1"
    )
  end

  def put
    @s3_client.put_object(
      bucket: "capybara-screenshots-production",
      acl: "public-read",
      key: @filename,
      body: @body,
      content_type: @content_type
    )
  end
end
