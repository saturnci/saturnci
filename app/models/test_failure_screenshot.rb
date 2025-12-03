class TestFailureScreenshot < ApplicationRecord
  belongs_to :test_case_run
  DEFAULT_EXPIRY = 7.days.to_i

  def url
    signer = Aws::S3::Presigner.new(client: S3ClientFactory.client)

    signer.presigned_url(
      :get_object,
      bucket: ENV["DIGITALOCEAN_SPACES_BUCKET_NAME"],
      key: path,
      expires_in: DEFAULT_EXPIRY
    )
  end
end
