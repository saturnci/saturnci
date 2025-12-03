require "rails_helper"
include APIAuthenticationHelper

describe "TestFailureScreenshots", type: :request do
  let!(:run) { create(:run, :with_test_runner) }
  let!(:test_runner) { run.test_runner }
  let!(:test_case_run) { create(:test_case_run, run: run, line_number: 307) }

  let!(:png_file) do
    path = Rails.root.join("spec", "support", "images", "screenshot.png")
    Rack::Test::UploadedFile.new(
      path,
      "image/png",
      original_filename: "failures_r_spec_example_test_case_307.png"
    )
  end

  before do
    spaces_file_upload = instance_double(SpacesFileUpload, put: true)
    allow(SpacesFileUpload).to receive(:new).and_return(spaces_file_upload)
  end

  describe "POST /api/v1/worker_agents/runs/:run_id/test_failure_screenshots" do
    def post_request
      post(
        api_v1_worker_agents_run_test_failure_screenshots_path(run_id: run.id),
        params: { file: png_file },
        headers: worker_agents_api_authorization_headers(test_runner)
      )
    end

    it "returns 200" do
      post_request
      expect(response.status).to eq(200)
    end

    it "creates a TestFailureScreenshot linked to the matching test case run" do
      expect { post_request }.to change { TestFailureScreenshot.count }.by(1)
      expect(TestFailureScreenshot.last.test_case_run).to eq(test_case_run)
    end
  end
end
