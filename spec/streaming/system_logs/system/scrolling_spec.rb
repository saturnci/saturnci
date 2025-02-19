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
    is_bottom_line_visible = page.evaluate_script(<<-JS)
      (function() {
        var element = document.evaluate(
          "//*[contains(text(), 'bottom line')]",
          document,
          null,
          XPathResult.FIRST_ORDERED_NODE_TYPE,
          null
        ).singleNodeValue;

        if (!element) {
          return false;
        } else {
          var rect = element.getBoundingClientRect();
          return rect.top < window.innerHeight && rect.bottom >= 0;
        }
      })();
    JS

    expect(is_bottom_line_visible).to be_truthy
  end
end
