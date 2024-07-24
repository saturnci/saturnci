require "rails_helper"

describe "Scrolling", type: :system do
  let!(:job) do
    create(:job, system_logs: ("line\n" * 500) + "bottom line")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "system_logs")
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
