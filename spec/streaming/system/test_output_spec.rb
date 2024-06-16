require "rails_helper"

describe "Test output streaming", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:job) do
    create(:job, test_output: "original test output content")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "test_output")
  end

  context "before log update occurs" do
    it "shows the original content" do
      expect(page).to have_content("original test output content")
    end
  end

  context "after the first log update occurs" do
    before do
      http_request(
        api_authorization_headers: api_authorization_headers,
        path: api_v1_job_test_output_path(job_id: job.id, format: :json),
        body: "new test output content"
      )
    end

    it "shows the new content" do
      expect(page).to have_content("new test output content")
    end
  end
end
