require "rails_helper"
include APIAuthenticationHelper

describe "Screenshots", type: :request do
  let!(:run) { create(:run, :with_test_runner) }
  let!(:test_runner) { run.test_runner }

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
      api_v1_test_runner_agents_run_screenshots_path(run_id: run.id),
      params: { screenshot: screenshot_file },
      headers: test_runner_agents_api_authorization_headers(test_runner).merge(
        "Content-Type" => "application/tar",
        "X-Filename" => "screenshot.tar.gz"
      )
    )

    expect(response.status).to eq(200)
  end

  it "saves a screenshot record" do
    expect {
      post(
        api_v1_test_runner_agents_run_screenshots_path(run_id: run.id),
        params: { screenshot: screenshot_file },
        headers: test_runner_agents_api_authorization_headers(test_runner).merge(
          "Content-Type" => "application/tar",
          "X-Filename" => "screenshot.tar.gz"
        )
      )
    }.to change { Screenshot.count }.by(1)
  end

  context "raw error" do
    before do
      post(
        api_v1_test_runner_agents_run_screenshots_path(run_id: run.id),
        headers: test_runner_agents_api_authorization_headers(test_runner)
      )
    end

    it "returns the error message" do
      expect(response.body["error"]).to be_present
    end

    it "returns a 400 status code" do
      expect(response.status).to eq(400)
    end
  end
end
