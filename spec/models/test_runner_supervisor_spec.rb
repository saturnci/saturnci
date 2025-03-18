require "rails_helper"

describe TestRunnerSupervisor do
  describe ".check" do
    context "an assigned test runner hasn't started running within 5 minutes" do
      it "deletes the assignment" do
        allow(TestRunner).to receive(:create_vm)
        test_runner_assignment = create(:test_runner_assignment)

        travel_to(10.minutes.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be false
        end
      end
    end

    context "an assigned test runner HAS started running within 5 minutes" do
      it "does not delete the assignment" do
        allow(TestRunner).to receive(:create_vm)
        test_runner_assignment = create(:test_runner_assignment)

        travel_to(2.minutes.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
        end
      end
    end
  end
end
