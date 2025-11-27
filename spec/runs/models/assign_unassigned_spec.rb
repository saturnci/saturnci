require "rails_helper"

describe "Assigning unassigned runs" do
  context "a test runner is available" do
    it "assigns a run to that test runner" do
      test_runner = create(:test_runner)
      run = create(:run)

      allow(TestRunner).to receive(:available).and_return([test_runner])
      allow(TestRunner).to receive(:create_vm)

      expect {
        Dispatcher.check
      }.to change { run.reload.test_runner }.from(nil).to(test_runner)
    end
  end
end
