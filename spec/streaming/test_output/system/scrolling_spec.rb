require "rails_helper"

describe "Test output scrolling", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper
  
  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "test_output")
    sleep 0.3 # Allow DOM to render
  end

  context "no scrolling" do
    let!(:run) do
      create(:run, test_output: ("line\n" * 500) + "bottom line")
    end

    it "scrolls to the bottom" do
      log_console = PageObjects::LogConsole.new(page)
      expect(log_console).to have_visible_text("bottom line")
    end
  end

  context "when user scrolls up" do
    let!(:run) do
      create(:run, test_output: ("line\n" * 500) + "bottom line")
    end

    it "pauses auto-scroll" do
      log_console = PageObjects::LogConsole.new(page)
      expect(log_console).to have_visible_text("bottom line")

      page.execute_script("""
        const runDetails = document.querySelector('.run-details');
        runDetails.scrollTop -= 50;
      """)

      new_content = "\ntop of new content\n" + ("middle line\n" * 100) + "bottom of new content"
      http_request(
        api_authorization_headers: api_authorization_headers(run.build.project.user),
        path: api_v1_run_test_output_path(run_id: run.id, format: :json),
        body: Base64.encode64(new_content)
      )

      expect(log_console).not_to have_visible_text("bottom of new content")

      page.execute_script("document.querySelector('.run-details').scrollTop = document.querySelector('.run-details').scrollHeight")
      expect(log_console).to have_visible_text("bottom of new content")
    end
  end
end
