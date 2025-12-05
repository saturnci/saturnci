require "rails_helper"

describe TestRunOrchestrationCheck do
  describe "#unassigned_runs" do
    context "when a repository uses the terra worker architecture" do
      let!(:repository) { create(:repository, worker_architecture: WorkerArchitecture.terra) }
      let!(:test_suite_run) { create(:test_suite_run, repository:) }
      let!(:run) { create(:run, test_suite_run:) }

      it "includes the run in unassigned_runs" do
        check = TestRunOrchestrationCheck.new
        expect(check.unassigned_runs).to include(run)
      end
    end

    context "when a repository uses a non-terra worker architecture" do
      let!(:repository) { create(:repository, worker_architecture: WorkerArchitecture.nova) }
      let!(:test_suite_run) { create(:test_suite_run, repository:) }
      let!(:run) { create(:run, test_suite_run:) }

      it "excludes the run from unassigned_runs" do
        check = TestRunOrchestrationCheck.new
        expect(check.unassigned_runs).not_to include(run)
      end
    end
  end
end
