require "rails_helper"

describe "Test output streaming", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:run) do
    create(:run, test_output: "original test output content")
  end

  before do
    login_as(run.build.project.user, scope: :user)
    visit job_path(run, "test_output")
  end

  context "before log update occurs" do
    it "shows the original content" do
      expect(page).to have_content("original test output content")
    end
  end

  context "after the first log update occurs" do
    before do
      expect(page).to have_content("original test output content") # To prevent race condition

      http_request(
        api_authorization_headers: api_authorization_headers,
        path: api_v1_run_test_output_path(run_id: run.id, format: :json),
        body: Base64.encode64("new test output content")
      )
    end

    it "shows the new content" do
      expect(page).to have_content("new test output content")
    end
  end
end
