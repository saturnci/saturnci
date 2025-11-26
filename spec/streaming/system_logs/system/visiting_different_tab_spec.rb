require "rails_helper"

describe "Visiting different tab", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:run) do
    create(:run, :with_test_runner) do |run|
      create(:runner_system_log, run:, content: "original system log content")
    end
  end

  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "system_logs")
  end

  context "visiting a different tab" do
    context "after log update occurs" do
      before do
        visit run_path(run, "test_output")

        http_request(
          api_authorization_headers: test_runner_agents_api_authorization_headers(run.test_runner),
          path: api_v1_test_runner_agents_run_system_logs_path(run_id: run.id, format: :json),
          body: "new system log content"
        )
      end

      it "does not show the system log content" do
        expect(page).not_to have_content("new system log content")
      end
    end
  end
end
