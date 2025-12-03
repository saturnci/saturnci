require "rails_helper"

describe ScreenshotFile do
  describe "#matching_test_case_run" do
    let!(:run) { create(:run) }

    let!(:screenshot_file) do
      ScreenshotFile.new(
        path: "failures_rspec_example_groups_show_new_test_suite_run_test_suite_run_created_via_api_shows_the_new_test_suite_run_991.png"
      )
    end

    context "test case run description matches" do
      let!(:test_case_run) do
        create(
          :test_case_run,
          run: run,
          description: "Show new test suite run test suite run created via API shows the new test suite run"
        )
      end

      it "returns the test case run" do
        expect(screenshot_file.matching_test_case_run(run)).to eq(test_case_run)
      end
    end

    context "test case run description does not match" do
      let!(:test_case_run) do
        create(
          :test_case_run,
          run: run,
          description: "Something completely different"
        )
      end

      it "does not return the test case run" do
        expect(screenshot_file.matching_test_case_run(run)).to be_nil
      end
    end

    context "test case run description contains special characters" do
      let!(:screenshot_file) do
        ScreenshotFile.new(
          path: "failures_rspec_doesn_t_cause_a_problem_696.png"
        )
      end

      let!(:test_case_run) do
        create(
          :test_case_run,
          run: run,
          description: "doesn't cause a problem"
        )
      end

      it "returns the test case run" do
        expect(screenshot_file.matching_test_case_run(run)).to eq(test_case_run)
      end
    end
  end
end
