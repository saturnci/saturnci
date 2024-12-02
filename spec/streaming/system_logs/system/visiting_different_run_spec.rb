require "rails_helper"

describe "Visiting different run", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper
  include NavigationHelper

  let!(:original_run) do
    create(:run, system_logs: "original system log content")
  end

  before do
    login_as(original_run.build.project.user, scope: :user)
    visit run_path(original_run, "system_logs")
  end

  context "visiting a different run" do
    let!(:other_run) do
      create(
        :run,
        build: original_run.build,
        system_logs: "other run system logs",
        order_index: 2
      )
    end

    context "after log update occurs" do
      before do
        visit_build_tab("system_logs", run: original_run)
        expect(page).to have_content(original_run.system_logs) # To prevent race condition

        navigate_to_run_tab(other_run)
        system_log_http_request(run: original_run, body: "new system log content")
      end

      it "does not show original run's system logs on the other run's system logs tab" do
        expect(page).not_to have_content(original_run.system_logs)
      end

      it "shows the other run's system logs on the other run's system logs tab" do
        expect(page).to have_content(other_run.system_logs)
      end
    end
  end
end
