require "rails_helper"

describe TestRunnerFleet, "pruning" do
  before do
    allow(Worker).to receive(:create_vm)
    allow_any_instance_of(Worker).to receive(:deprovision)
    allow(Dispatcher).to receive(:log)
  end

  let!(:c) { TestRunOrchestrationCheck.new }

  before do
    allow(TestRunnerFleet).to receive(:target_size).and_return(4)
  end

  context "there are 6 unassigned test runners" do
    it "deletes an unassigned test runner" do
      create_list(:test_runner, 5)
      test_runner_fleet = TestRunnerFleet.instance
      expect { test_runner_fleet.prune }.to change(Worker, :count).by(-1)
    end
  end

  context "there are 4 unassigned test runners and 2 more in error" do
    it "deletes the 2 errored test runners" do
      create_list(:test_runner, 4)

      2.times do
        test_runner = create(:test_runner)
        test_runner.worker_events.create!(type: :error)
      end

      expect { Dispatcher.check(c) }.to change(Worker, :count).by(-2)
    end
  end

  context "there's an unassigned test runner that's more than an hour old" do
    it "deletes it" do
      test_runner = create(:test_runner)

      travel_to(2.hours.from_now) do
        expect { Dispatcher.check }.to change { Worker.exists?(test_runner.id) }.to(false)
      end
    end
  end

  context "there's an assigned test runner that's more than an hour old" do
    it "does not delete it" do
      test_runner = create(:test_runner_assignment).worker

      travel_to(2.hours.from_now) do
        expect { Dispatcher.check(c) }.to_not change { Worker.exists?(test_runner.id) }
      end
    end
  end

  context "there's an assigned test runner that's more than a day old" do
    it "deletes it" do
      test_runner = create(:test_runner_assignment).worker

      travel_to(2.days.from_now) do
        expect { Dispatcher.check(c) }.to change { Worker.exists?(test_runner.id) }.from(true).to(false)
      end
    end
  end

end
