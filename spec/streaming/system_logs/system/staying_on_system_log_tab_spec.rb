require "rails_helper"

describe "Staying on system log tab", type: :system do
  include SaturnAPIHelper

  let!(:run) do
    create(:run) do |run|
      create(:runner_system_log, run:, content: "original system log content")
    end
  end

  let!(:user) { run.build.project.user }

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
          api_authorization_headers: api_authorization_headers(user),
          path: api_v1_run_system_logs_path(run_id: run.id, format: :json),
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
            api_authorization_headers: api_authorization_headers(user),
            path: api_v1_run_system_logs_path(run_id: run.id, format: :json),
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
