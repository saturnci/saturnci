require "rails_helper"

describe "Automatic failure rerun retries" do
  describe TestSuiteRunFinish do
    context "when below retry limit" do
      let!(:failure_rerun_1) { create(:failure_rerun) }
      let!(:failure_rerun_2) { create(:failure_rerun, original_test_suite_run: failure_rerun_1.test_suite_run) }

      let!(:current_rerun) { failure_rerun_2.test_suite_run }
      let!(:task) { create(:run, test_suite_run: current_rerun) }
      let!(:failed_test_case_run) { create(:test_case_run, run: task, status: "failed") }

      before do
        allow(current_rerun).to receive(:check_test_case_run_integrity!)
      end

      it "creates a new rerun" do
        expect { TestSuiteRunFinish.new(current_rerun).process }
          .to change { TestSuiteRun.count }.by(1)
      end
    end

    context "when retry limit has been reached" do
      let!(:failure_rerun_1) { create(:failure_rerun) }
      let!(:failure_rerun_2) { create(:failure_rerun, original_test_suite_run: failure_rerun_1.test_suite_run) }
      let!(:failure_rerun_3) { create(:failure_rerun, original_test_suite_run: failure_rerun_2.test_suite_run) }

      let!(:final_rerun) { failure_rerun_3.test_suite_run }
      let!(:task) { create(:run, test_suite_run: final_rerun) }
      let!(:failed_test_case_run) { create(:test_case_run, run: task, status: "failed") }

      before do
        allow(final_rerun).to receive(:check_test_case_run_integrity!)
      end

      it "does not create another rerun" do
        expect { TestSuiteRunFinish.new(final_rerun).process }
          .not_to change { TestSuiteRun.count }
      end
    end
  end
end
