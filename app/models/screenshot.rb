class Screenshot < ApplicationRecord
  belongs_to :build
  DEFAULT_EXPIRY = 3600

  def url
    signer = Aws::S3::Presigner.new(client: S3ClientFactory.client)

    signer.presigned_url(
      :get_object,
      bucket: ENV["DIGITALOCEAN_SPACES_BUCKET_NAME"],
      key: path,
      expires_in: DEFAULT_EXPIRY
    )
  end

  def label
    File.basename(path)
  end
end
