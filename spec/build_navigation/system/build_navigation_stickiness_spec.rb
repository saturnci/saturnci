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

      page.execute_script('document.querySelector(".job-info-container").scrollTop = document.querySelector(".job-info-container").scrollHeight')

      visible = page.evaluate_script(<<~JS)
        (function() {
          var container = document.querySelector(".job-info-container");
          var textToFind = "bottom of test output";
          return container.scrollTop + container.clientHeight >= container.scrollHeight &&
            container.innerText.includes(textToFind);
        })();
      JS
      expect(visible).to eq(true)

      expect(page).to have_content("Test Output")
    end
  end
end
