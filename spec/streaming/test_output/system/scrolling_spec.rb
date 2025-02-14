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
