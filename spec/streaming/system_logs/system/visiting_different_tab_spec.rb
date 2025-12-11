require "rails_helper"

describe "Visiting different tab", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:run) do
    create(:run, :with_worker) do |run|
      create(:runner_system_log, task: run, content: "original system log content")
    end
  end

  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "system_logs")
  end

  context "visiting a different tab" do
    context "after log update occurs" do
      before do
        visit run_path(run, "events")

        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(run.worker),
          path: api_v1_worker_agents_task_system_logs_path(task_id: run.id, format: :json),
          body: "new system log content"
        )
      end

      it "does not show the system log content" do
        expect(page).not_to have_content("new system log content")
      end
    end
  end
end
