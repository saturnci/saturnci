require "rails_helper"

describe ScreenshotFile do
  describe "#line_number" do
    it "extracts line number from filename" do
      screenshot_file = ScreenshotFile.new(
        path: "/tmp/failures_r_spec_example_shows_save_error_307.png"
      )

      expect(screenshot_file.line_number).to eq(307)
    end
  end

  describe "#matching_test_case_run" do
    let!(:screenshot_file) do
      ScreenshotFile.new(
        path: "/tmp/failures_r_spec_example_shows_save_error_307.png"
      )
    end

    let!(:run) { create(:run) }

    context "test case run line number matches" do
      let!(:test_case_run) do
        create(:test_case_run, run: run, line_number: 307)
      end

      it "returns the test case" do
        expect(screenshot_file.matching_test_case_run(run)).to eq(test_case_run)
      end
    end

    context "test case run line number does not match" do
      let!(:test_case_run) do
        create(:test_case_run, run: run, line_number: 111)
      end

      it "returns the test case" do
        expect(screenshot_file.matching_test_case_run(run)).not_to eq(test_case_run)
      end
    end
  end
end
