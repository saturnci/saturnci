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
    sleep 0.3 # Allow DOM to render
  end

  it "scrolls to the bottom" do
    log_console = PageObjects::LogConsole.new(page)
    expect(log_console).to have_visible_text("bottom line")
  end

  context "when user scrolls up" do
    it "pauses auto-scroll" do
      log_console = PageObjects::LogConsole.new(page)
      expect(log_console).to have_visible_text("bottom line")

      # User scrolls up manually
      page.execute_script("""
        const runDetails = document.querySelector('.run-details');
        runDetails.scrollTop = 0;
        runDetails.dispatchEvent(new Event('scroll'));
      """)
      
      # Give time for scroll event to be processed
      sleep 0.1

      # New content arrives via API
      new_content = "\ntop of new content\n" + ("middle line\n" * 100) + "bottom of new content"
      http_request(
        api_authorization_headers: api_authorization_headers(run.build.project.user),
        path: api_v1_run_test_output_path(run_id: run.id, format: :json),
        body: Base64.encode64(new_content)
      )

      expect(page).to have_content("top of new content")
      expect(page).not_to have_content("bottom of new content")
    end
  end
end
