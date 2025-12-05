require "rails_helper"

describe "TestSuiteRun#start!" do
  context "when repository uses terra architecture" do
    let!(:repository) { create(:repository, worker_architecture: WorkerArchitecture.terra) }
    let!(:test_suite_run) { create(:test_suite_run, repository:) }

    it "calls Terra.start_test_suite_run" do
      expect(Terra).to receive(:start_test_suite_run).with(test_suite_run)
      test_suite_run.start!
    end
  end

  context "when repository uses nova architecture" do
    let!(:repository) { create(:repository, worker_architecture: WorkerArchitecture.nova) }
    let!(:test_suite_run) { create(:test_suite_run, repository:) }

    it "calls Nova.start_test_suite_run" do
      expect(Nova).to receive(:start_test_suite_run).with(test_suite_run)
      test_suite_run.start!
    end
  end
end
