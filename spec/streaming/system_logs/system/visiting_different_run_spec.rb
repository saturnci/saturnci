require "rails_helper"

describe "Visiting different run", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper
  include NavigationHelper

  let!(:original_run) do
    create(:run, :with_worker) do |run|
      create(:runner_system_log, task: run, content: "original system log content")
    end
  end

  before do
    login_as(original_run.build.project.user, scope: :user)
    visit run_path(original_run, "system_logs")
  end

  context "visiting a different run" do
    let!(:other_run) do
      create(:run, build: original_run.build, order_index: 2) do |run|
        create(:runner_system_log, task: run, content: "other run system logs")
      end
    end

    context "after log update occurs" do
      before do
        visit_build_tab("system_logs", run: original_run)
        expect(page).to have_content(original_run.runner_system_log.content)

        navigate_to_run_tab(other_run)
        system_log_http_request(run: original_run, body: "new system log content")
      end

      it "does not show original run's system logs on the other run's system logs tab" do
        expect(page).not_to have_content(original_run.runner_system_log.content)
      end

      it "shows the other run's system logs on the other run's system logs tab" do
        expect(page).to have_content(other_run.runner_system_log.content)
      end
    end
  end
end
