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
      visit job_detail_content_project_build_job_path(
        project_id: job.build.project.id,
        build_id: job.build.id,
        id: job.id,
        partial: "test_output"
      )

      page.execute_script('document.querySelector(".build-details-content-container").scrollTop = document.querySelector(".build-details-content-container").scrollHeight')

      scrollable = page.evaluate_script(<<~JS)
        (function() {
          var container = document.querySelector(".build-details-content-container");
          return container.scrollHeight > container.clientHeight;
        })();
      JS

      expect(scrollable).to eq(true), "The log pane is not scrollable"
      expect(page).to have_content("Test Output")
    end
  end
end
