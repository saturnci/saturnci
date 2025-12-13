require "rails_helper"

describe "Test suite run navigation stickiness", type: :system do
  let!(:run) { create(:run) }
  let!(:runner_system_log) do
    content = ("asdf\n" * 1000) + "bottom of system logs"
    create(:runner_system_log, task: run, content: content)
  end

  before do
    login_as(run.test_suite_run.repository.user)
  end

  context "the log pane is scrolled all the way to the bottom" do
    it "keeps the test suite run navigation visible" do
      visit task_path(run, "system_logs")

      page.execute_script('document.querySelector(".run-details").scrollTop = document.querySelector(".run-details").scrollHeight')

      scrollable = page.evaluate_script(<<~JS)
        (function() {
          var container = document.querySelector(".run-details");
          return container.scrollHeight > container.clientHeight;
        })();
      JS

      expect(scrollable).to eq(true), "The log pane is not scrollable"
      expect(page).to have_content("System Logs")
    end
  end
end
