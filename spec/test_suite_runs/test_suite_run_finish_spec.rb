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
        allow(Nova).to receive(:create_k8s_job)
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

      it "creates a worker for the rerun task" do
        expect { TestSuiteRunFinish.new(test_suite_run).process }
          .to change { Worker.count }.by(1)
      end

      it "broadcasts the rerun test suite run" do
        expect_any_instance_of(TestSuiteRun).to receive(:broadcast)
        TestSuiteRunFinish.new(test_suite_run).process
      end

      it "sets dry_run_example_count to the number of failed test cases" do
        rerun_test_suite_run = TestSuiteRunFinish.new(test_suite_run).process
        expect(rerun_test_suite_run.dry_run_example_count).to eq(1)
      end

      context "when the original test suite run has a started_by_user" do
        let!(:user) { create(:user) }

        before do
          test_suite_run.update!(started_by_user: user)
        end

        it "copies the started_by_user to the rerun" do
          rerun_test_suite_run = TestSuiteRunFinish.new(test_suite_run).process
          expect(rerun_test_suite_run.started_by_user).to eq(user)
        end
      end

      context "when the test suite run has already been retried 3 times" do
        let!(:original_tsr) { create(:test_suite_run) }

        let!(:retry_1) { create(:test_suite_run, repository: original_tsr.repository) }
        let!(:failure_rerun_1) { create(:failure_rerun, original_test_suite_run: original_tsr, test_suite_run: retry_1) }

        let!(:retry_2) { create(:test_suite_run, repository: original_tsr.repository) }
        let!(:failure_rerun_2) { create(:failure_rerun, original_test_suite_run: retry_1, test_suite_run: retry_2) }

        let!(:retry_3) { create(:test_suite_run, repository: original_tsr.repository) }
        let!(:failure_rerun_3) { create(:failure_rerun, original_test_suite_run: retry_2, test_suite_run: retry_3) }

        let!(:task) { create(:run, test_suite_run: retry_3) }
        let!(:failed_test_case_run) { create(:test_case_run, task:, status: "failed") }

        before do
          allow(retry_3).to receive(:check_test_case_run_integrity!)
        end

        it "does not create a new test suite run" do
          expect { TestSuiteRunFinish.new(retry_3).process }
            .not_to change { TestSuiteRun.count }
        end
      end
    end
  end
end
