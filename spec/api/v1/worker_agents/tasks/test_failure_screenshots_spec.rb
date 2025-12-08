require "rails_helper"
include APIAuthenticationHelper

describe "TestFailureScreenshots", type: :request do
  let!(:task) { create(:run, :with_worker) }
  let!(:worker) { task.worker }
  let!(:test_case_run) do
    create(:test_case_run, task: task, description: "User login shows error message")
  end

  let!(:png_file) do
    path = Rails.root.join("spec", "support", "images", "screenshot.png")
    Rack::Test::UploadedFile.new(path, "image/png")
  end

  before do
    spaces_file_upload = instance_double(SpacesFileUpload, put: true)
    allow(SpacesFileUpload).to receive(:new).and_return(spaces_file_upload)
  end

  describe "POST /api/v1/worker_agents/tasks/:task_id/test_failure_screenshots" do
    def post_request
      post(
        api_v1_worker_agents_task_test_failure_screenshots_path(task_id: task.id),
        params: { file: png_file },
        headers: worker_agents_api_authorization_headers(worker).merge(
          "Content-Type" => "image/png",
          "X-Filename" => "failures_rspec_user_login_shows_error_message_123.png"
        )
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
