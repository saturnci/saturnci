require "rails_helper"

describe "System logs scrolling", type: :system do
  let!(:run) do
    create(:run) do |run|
      create(:runner_system_log, run:, content: ("line\n" * 500) + "bottom line")
    end
  end

  before do
    login_as(run.build.project.user)
    visit run_path(run, "system_logs")
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
end
