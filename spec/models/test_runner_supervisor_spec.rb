require "rails_helper"

describe TestRunnerSupervisor do
  before do
    allow(TestRunner).to receive(:create_vm)
    allow_any_instance_of(TestRunner).to receive(:deprovision)
  end

  describe ".check" do
    context "run already finished" do
      let!(:run) { create(:run, :passed) }

      before do
        allow(TestRunner).to receive(:available).and_return([create(:test_runner)])
      end

      it "does not add an assignment" do
        expect { TestRunnerSupervisor.check }.to_not change(TestRunnerAssignment, :count)
      end
    end

    context "an assigned test runner hasn't started running within 5 minutes" do
      let!(:test_runner_assignment) { create(:test_runner_assignment) }

      it "deletes the assignment" do
        travel_to(10.minutes.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be false
        end
      end

      it "deletes the test runner" do
        travel_to(10.minutes.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunner.exists?(test_runner_assignment.test_runner.id)).to be false
        end
      end
    end

    context "an assigned test runner HAS started running within 5 minutes" do
      it "does not delete the assignment" do
        test_runner_assignment = create(:test_runner_assignment)

        travel_to(2.minutes.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
        end
      end
    end
  end
end
