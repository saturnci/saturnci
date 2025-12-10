require "rails_helper"

describe "Navigating from test output tab", type: :system do
  include SaturnAPIHelper
  include NavigationHelper

  let!(:run) do
    create(:run, :with_worker) do |run|
      create(:runner_system_log, task: run, content: "stuff")
    end
  end

  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "test_output")
  end

  context "navigating to the system logs tab" do
    before do
      navigate_to_build_tab("system_logs", run:)

      http_request(
        api_authorization_headers: worker_agents_api_authorization_headers(run.worker),
        path: api_v1_worker_agents_task_system_logs_path(task_id: run.id, format: :json),
        body: Base64.encode64("new system log content")
      )
    end

    it "shows the new content" do
      expect(page).to have_content("new system log content")
    end
  end
end
