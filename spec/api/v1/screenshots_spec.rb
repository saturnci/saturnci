require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "Screenshots", type: :request do
  let!(:run) { create(:run) }

  let!(:screenshot_file) do
    path = Rails.root.join("spec", "support", "images", "screenshot.png")
    Rack::Test::UploadedFile.new(path, "image/png")
  end

  before do
    spaces_file_upload = instance_double(SpacesFileUpload, put: true)
    allow(SpacesFileUpload).to receive(:new).and_return(spaces_file_upload)
  end

  it "works" do
    post(
      api_v1_run_screenshots_path(run_id: run.id),
      params: { screenshot: screenshot_file },
      headers: api_authorization_headers(run.build.project.user).merge(
        "Content-Type" => "image/png",
        "X-Filename" => "screenshot.png"
      )
    )

    expect(response.status).to eq(200)
  end
end
