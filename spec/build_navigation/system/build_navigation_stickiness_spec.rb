require "rails_helper"

describe "Build navigation stickiness", type: :system do
  let!(:job) do
    test_output = ("asdf\n" * 1000) + "bottom of test output"
    create(:job, test_output: test_output)
  end

  before do
    login_as(job.build.project.user, scope: :user)
  end

  context "the log pane is scrolled all the way to the bottom" do
    it "keeps the build navigation visible" do
      visit job_path(job, "test_output")

      page.execute_script('document.querySelector(".job-details").scrollTop = document.querySelector(".job-details").scrollHeight')

      scrollable = page.evaluate_script(<<~JS)
        (function() {
          var container = document.querySelector(".job-details");
          return container.scrollHeight > container.clientHeight;
        })();
      JS

      expect(scrollable).to eq(true), "The log pane is not scrollable"
      expect(page).to have_content("Test Output")
    end
  end
end
