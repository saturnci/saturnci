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

    context "an assigned test runner hasn't started running within 30 seconds" do
      let!(:test_runner_assignment) { create(:test_runner_assignment) }

      it "deletes the assignment" do
        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be false
        end
      end

      it "puts the test runner in error status" do
        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(test_runner_assignment.test_runner.status).to eq("Error")
        end
      end

      context "run is more than a day old" do
        it "does not delete the assignment" do
          travel_to(25.hours.from_now) do
            TestRunnerSupervisor.check
            expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
          end
        end
      end
    end

    context "an assigned test runner HAS started running within 30 seconds" do
      it "does not delete the assignment" do
        test_runner_assignment = create(:test_runner_assignment)

        create(
          :test_runner_event,
          test_runner: test_runner_assignment.test_runner,
          type: :assignment_acknowledged
        )

        travel_to(60.seconds.from_now) do
          TestRunnerSupervisor.check
          expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
        end
      end
    end
  end
end
