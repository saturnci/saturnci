require "rails_helper"

describe "Build navigation stickiness", type: :system do
  let!(:run) do
    test_output = ("asdf\n" * 1000) + "bottom of test output"
    create(:run, test_output: test_output)
  end

  before do
    allow_any_instance_of(User).to receive(:can_hit_github_api?).and_return(true)
    login_as(run.build.project.user)
  end

  context "the log pane is scrolled all the way to the bottom" do
    it "keeps the build navigation visible" do
      visit run_path(run, "test_output")

      page.execute_script('document.querySelector(".run-details").scrollTop = document.querySelector(".run-details").scrollHeight')

      scrollable = page.evaluate_script(<<~JS)
        (function() {
          var container = document.querySelector(".run-details");
          return container.scrollHeight > container.clientHeight;
        })();
      JS

      expect(scrollable).to eq(true), "The log pane is not scrollable"
      expect(page).to have_content("Test Output")
    end
  end
end
