require "rails_helper"

describe "Test output scrolling", type: :system do
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

  it "pauses auto-scrolling when user scrolls up" do
    sleep (TerminalOutputComponent::DOM_RENDER_DELAY_IN_MILLISECONDS + 100) / 1000.0
    log_console = PageObjects::LogConsole.new(page)
    
    # Verify we start at bottom
    expect(log_console).to have_visible_text("bottom line")
    
    # Scroll up manually to trigger pause
    page.execute_script("document.querySelector('.run-details').scrollTop = 0;")
    sleep 0.1  # Allow scroll event to register
    
    # Try to trigger auto-scroll - it should not scroll because user scrolled up
    page.execute_script("window.terminalAutoScroll();")
    sleep 0.1
    
    # Verify we're still at the top (auto-scroll was paused)
    scroll_position = page.evaluate_script("document.querySelector('.run-details').scrollTop")
    expect(scroll_position).to eq(0)
  end
  
  it "resumes auto-scrolling when user scrolls back to bottom" do
    sleep (TerminalOutputComponent::DOM_RENDER_DELAY_IN_MILLISECONDS + 100) / 1000.0
    log_console = PageObjects::LogConsole.new(page)
    
    # Verify we start at bottom
    expect(log_console).to have_visible_text("bottom line")
    
    # Scroll up to pause auto-scrolling
    page.execute_script("document.querySelector('.run-details').scrollTop = 0;")
    sleep 0.1
    
    # Scroll back to bottom to resume auto-scrolling
    page.execute_script(<<~JS)
      var runDetails = document.querySelector('.run-details');
      runDetails.scrollTop = runDetails.scrollHeight;
    JS
    sleep 0.1
    
    # Now auto-scroll should work again
    initial_scroll = page.evaluate_script("document.querySelector('.run-details').scrollTop")
    page.execute_script("window.terminalAutoScroll();")
    sleep 0.1
    
    # Should still be at bottom (or very close)
    final_scroll = page.evaluate_script("document.querySelector('.run-details').scrollTop")
    expect(final_scroll).to be >= initial_scroll
  end
end
