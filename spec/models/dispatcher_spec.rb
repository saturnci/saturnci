require "rails_helper"

describe Dispatcher do
  before do
    allow(TestRunner).to receive(:create_vm)
    allow_any_instance_of(TestRunner).to receive(:deprovision)
    allow(Dispatcher).to receive(:log)
  end

  describe "fleet" do
    let!(:c) { TestRunOrchestrationCheck.new }

    before do
      allow(TestRunnerFleet).to receive(:target_size).and_return(4)
    end

    context "there are 3 test runners" do
      it "creates 1 test runner" do
        create_list(:test_runner, 3)
        expect { Dispatcher.check(c) }.to change(TestRunner, :count).by(1)
      end
    end

    context "there are 4 test runners" do
      it "does not create a test runner" do
        create_list(:test_runner, 4)
        expect { Dispatcher.check(c) }.to_not change(TestRunner, :count)
      end
    end

    context "there are 5 test runners but 4 of them are assigned" do
      it "creates 4 - 1 = 3 test runners" do
        create_list(:test_runner_assignment, 4)
        create(:test_runner)
        expect { Dispatcher.check(c) }.to change(TestRunner, :count).by(3)
      end
    end
  end

  context "run already finished" do
    let!(:run) { create(:run, :passed) }

    before do
      allow(TestRunner).to receive(:available).and_return([create(:test_runner)])
    end

    it "does not add an assignment" do
      expect { Dispatcher.check }.to_not change(TestRunnerAssignment, :count)
    end
  end

  context "an assigned test runner hasn't started running within 30 seconds" do
    let!(:test_runner_assignment) { create(:test_runner_assignment) }

    it "deletes the assignment" do
      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be false
      end
    end

    it "puts the test runner in error status" do
      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(test_runner_assignment.worker.status).to eq("Error")
      end
    end

    context "run is more than a day old" do
      before do
        allow(Dispatcher).to receive(:delete_test_runners)
      end

      it "does not delete the assignment" do
        travel_to(25.hours.from_now) do
          Dispatcher.check
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
        test_runner: test_runner_assignment.worker,
        type: :assignment_acknowledged
      )

      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(TestRunnerAssignment.exists?(test_runner_assignment.id)).to be true
      end
    end
  end

  context "a run has already been executed but its assignment was deleted" do
    it "does not reassign the run" do
      completed_run = create(:run, :passed)

      test_runner_assignment = create(:test_runner_assignment, run: completed_run)
      test_runner_assignment.destroy

      test_runner = create(:test_runner)
      allow(TestRunner).to receive(:available).and_return([test_runner])

      expect { Dispatcher.check }.to_not change(TestRunnerAssignment, :count)
    end
  end
end
