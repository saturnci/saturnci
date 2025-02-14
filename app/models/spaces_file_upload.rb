class SpacesFileUpload
  def initialize(filename:, body:, content_type:)
    @filename = filename
    @body = body
    @content_type = content_type
  end

  def put
    S3ClientFactory.client.put_object(
      bucket: ENV["DIGITALOCEAN_SPACES_BUCKET_NAME"],
      key: @filename,
      body: @body,
      content_type: @content_type
    )
  end
end
