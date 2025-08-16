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
end
