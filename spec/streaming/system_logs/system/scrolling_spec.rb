require "rails_helper"

describe "System logs scrolling", type: :system do
  let!(:run) do
    create(:run) do |run|
      create(:runner_system_log, task: run, content: ("line\n" * 500) + "bottom line")
    end
  end

  before do
    login_as(run.build.project.user)
    visit run_path(run, "system_logs")
  end

  it "scrolls to the bottom" do
    sleep 0.3 # Allow DOM to render
    log_console = PageObjects::LogConsole.new(page)
    expect(log_console).to have_visible_text("bottom line")
  end
end
