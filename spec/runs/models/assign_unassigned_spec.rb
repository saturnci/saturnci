require "rails_helper"

describe "Assigning unassigned runs" do
  context "a test runner is available" do
    it "assigns a run to that test runner" do
      test_runner = create(:test_runner)
      run = create(:run)

      allow(TestRunner).to receive(:available).and_return([test_runner])

      expect {
        Run.assign_unassigned
      }.to change { run.reload.test_runner }.from(nil).to(test_runner)
    end
  end
end
