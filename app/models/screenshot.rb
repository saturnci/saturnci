class Screenshot < ApplicationRecord
  belongs_to :build

  def url
    "https://capybara-screenshots-production.nyc3.digitaloceanspaces.com/#{path}"
  end

  def label
    File.basename(path)
  end
end
