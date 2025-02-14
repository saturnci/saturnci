class Screenshot < ApplicationRecord
  belongs_to :build

  def url
    "https://#{ENV["DIGITALOCEAN_SPACES_BUCKET_NAME"]}.nyc3.digitaloceanspaces.com/#{path}"
  end

  def label
    File.basename(path)
  end
end
