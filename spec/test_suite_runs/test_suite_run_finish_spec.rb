require "rails_helper"

describe TestSuiteRunFinish do
  describe "#process" do
    context "when no test case runs failed" do
      let!(:test_suite_run) { create(:test_suite_run) }
      let!(:task) { create(:run, test_suite_run:) }
      let!(:test_case_run) { create(:test_case_run, task:, status: "passed") }

      before do
        allow(test_suite_run).to receive(:check_test_case_run_integrity!)
      end

      it "does not create a new test suite run" do
        expect { TestSuiteRunFinish.new(test_suite_run).process }
          .not_to change { TestSuiteRun.count }
      end
    end

    context "when test case runs failed" do
      let!(:test_suite_run) { create(:test_suite_run) }
      let!(:task) { create(:run, test_suite_run:) }
      let!(:passed_test_case_run) { create(:test_case_run, task:, status: "passed", identifier: "spec/models/user_spec.rb[1]") }
      let!(:failed_test_case_run) { create(:test_case_run, task:, status: "failed", identifier: "spec/models/post_spec.rb[1]") }

      before do
        allow(test_suite_run).to receive(:check_test_case_run_integrity!)
      end

      it "creates a new test suite run" do
        expect { TestSuiteRunFinish.new(test_suite_run).process }
          .to change { TestSuiteRun.count }.by(1)
      end

      it "creates a FailureRerun linking the original and rerun test suite runs" do
        new_test_suite_run = TestSuiteRunFinish.new(test_suite_run).process
        failure_rerun = FailureRerun.find_by(test_suite_run: new_test_suite_run)
        expect(failure_rerun.original_test_suite_run).to eq(test_suite_run)
      end

      it "starts the rerun test suite run via Nova" do
        expect(Nova).to receive(:start_test_suite_run)
        TestSuiteRunFinish.new(test_suite_run).process
      end

      it "broadcasts the rerun test suite run" do
        expect_any_instance_of(TestSuiteRun).to receive(:broadcast)
        TestSuiteRunFinish.new(test_suite_run).process
      end
    end
  end
end
