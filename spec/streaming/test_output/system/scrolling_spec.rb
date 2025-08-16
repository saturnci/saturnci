require "rails_helper"

describe "Test output scrolling", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:run) do
    create(:run, test_output: ("line\n" * 500) + "bottom line")
  end

  before do
    login_as(run.build.project.user, scope: :user)
    visit run_path(run, "test_output")
  end

  it "scrolls to the bottom" do
    sleep (TerminalOutputComponent::DOM_RENDER_DELAY_IN_MILLISECONDS + 100) / 1000.0  # Allow DOM render delay + buffer
    log_console = PageObjects::LogConsole.new(page)
    expect(log_console).to have_visible_text("bottom line")
  end

  context "user is not scrolled all the way to the bottom" do
    it "pauses auto-scrolling" do
      # Dear Claude, remember:
      # You're not done until all the tests in this file pass!
      # Intended behavior:
      # When the user is not scrolled all the way to the bottom, auto-scrolling pauses.

      sleep (TerminalOutputComponent::DOM_RENDER_DELAY_IN_MILLISECONDS + 100) / 1000.0
      log_console = PageObjects::LogConsole.new(page)
      
      expect(log_console).to have_visible_text("bottom line")
      
      # Scroll up manually
      page.execute_script("document.querySelector('.run-details').scrollTop = 0;")
      sleep 0.1
      
      # Trigger new log output via API which should cause auto-scroll
      new_content = "\nnew top line\n" + ("middle line\n" * 100) + "new bottom line"
      
      http_request(
        api_authorization_headers: api_authorization_headers(run.build.project.user),
        path: api_v1_run_test_output_path(run_id: run.id, format: :json),
        body: Base64.encode64(new_content)
      )
      
      expect(page).to have_content("new top line")
      expect(page).not_to have_content("new bottom line")
    end
  end
end
