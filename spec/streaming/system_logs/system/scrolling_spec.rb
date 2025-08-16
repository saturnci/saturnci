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
end
