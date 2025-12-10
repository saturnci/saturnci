require "rails_helper"

describe "Staying on system log tab", type: :system do
  include SaturnAPIHelper

  let!(:run) do
    create(:run, :with_worker) do |run|
      create(:runner_system_log, task: run, content: "original system log content")
    end
  end

  let!(:user) { run.build.project.user }
  let!(:worker) { run.worker }

  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "system_logs")
  end

  context "before log update occurs" do
    it "shows the original content" do
      expect(page).to have_content("original system log content")
    end
  end

  context "staying on system log tab" do
    context "after the first log update occurs" do
      before do
        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(worker),
          path: api_v1_worker_agents_task_system_logs_path(task_id: run.id, format: :json),
          body: Base64.encode64("new system log content")
        )
      end

      it "shows the new content" do
        expect(page).to have_content("new system log content")
      end

      it "does not show the old content" do
        expect(page).to have_content("original system log content", count: 1)
      end

      context "after a second log update occurs" do
        before do
          http_request(
            api_authorization_headers: worker_agents_api_authorization_headers(worker),
            path: api_v1_worker_agents_task_system_logs_path(task_id: run.id, format: :json),
            body: Base64.encode64("second system log update")
          )
        end

        it "shows the new content" do
          expect(page).to have_content("second system log update")
        end
      end
    end
  end
end
