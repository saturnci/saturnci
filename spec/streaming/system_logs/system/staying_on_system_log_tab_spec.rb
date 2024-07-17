require "rails_helper"

describe "Staying on system log tab", type: :system do
  include SaturnAPIHelper

  let!(:job) do
    create(:job, system_logs: "original system log content")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "system_logs")
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
          api_authorization_headers: api_authorization_headers,
          path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
          body: "new system log content"
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
            api_authorization_headers: api_authorization_headers,
            path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
            body: "second system log update"
          )
        end

        it "shows the new content" do
          expect(page).to have_content("second system log update")
        end
      end
    end
  end
end
