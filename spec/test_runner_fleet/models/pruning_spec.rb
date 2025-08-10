require "rails_helper"

describe TestRunnerFleet, "pruning" do
  before do
    allow(TestRunner).to receive(:create_vm)
    allow_any_instance_of(TestRunner).to receive(:deprovision)
    allow(TestRunnerSupervisor).to receive(:log)
  end

  let!(:c) { TestRunOrchestrationCheck.new }

  before do
    allow(c).to receive(:test_runner_fleet_size).and_return(4)
  end

  context "there are 6 unassigned test runners" do
    it "deletes an unassigned test runner" do
      create_list(:test_runner, 5)
      test_runner_fleet = TestRunnerFleet.instance
      expect { test_runner_fleet.prune(c) }.to change(TestRunner, :count).by(-1)
    end
  end

  context "there are 4 unassigned test runners and 2 more in error" do
    it "deletes the 2 errored test runners" do
      create_list(:test_runner, 4)

      2.times do
        test_runner = create(:test_runner)
        test_runner.test_runner_events.create!(type: :error)
      end

      expect { TestRunnerSupervisor.check(c) }.to change(TestRunner, :count).by(-2)
    end
  end

  context "there's an unassigned test runner that's more than an hour old" do
    it "deletes it" do
      test_runner = create(:test_runner)

      travel_to(2.hours.from_now) do
        expect { TestRunnerSupervisor.check }.to change { TestRunner.exists?(test_runner.id) }.to(false)
      end
    end
  end

  context "there's an assigned test runner that's more than an hour old" do
    it "does not delete it" do
      test_runner = create(:test_runner_assignment).test_runner

      travel_to(2.hours.from_now) do
        expect { TestRunnerSupervisor.check(c) }.to_not change { TestRunner.exists?(test_runner.id) }
      end
    end
  end

  context "there's an assigned test runner that's more than a day old" do
    it "deletes it" do
      test_runner = create(:test_runner_assignment).test_runner

      travel_to(2.days.from_now) do
        expect { TestRunnerSupervisor.check(c) }.to change { TestRunner.exists?(test_runner.id) }.from(true).to(false)
      end
    end
  end
end
