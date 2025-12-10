require "rails_helper"

describe "Visiting different build", type: :system do
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

  context "visiting a different build" do
    let!(:other_run) do
      create(:run) do |j|
        create(:runner_system_log, task: j, content: "other run system logs")

        j.build.update!(
          project: original_run.build.project,
          commit_message: "Make other change."
        )
      end
    end

    context "after log update occurs" do
      before do
        visit_build_tab("system_logs", run: original_run)
        navigate_to_build(other_run.build)
        navigate_to_build_tab("system_logs", run: other_run)
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
