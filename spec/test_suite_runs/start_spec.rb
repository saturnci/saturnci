require "rails_helper"

describe "Starting test suite run" do
  let!(:project) { create(:project, concurrency: 2) }
  let!(:test_suite_run) { create(:build, project:) }

  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  context "there were initially no test runners, then some became available" do
    let!(:test_runners) do
      create_list(:test_runner, 2)
    end

    before do
      allow(TestRunner).to receive(:provision)

      allow(TestRunner).to receive_message_chain(:available, :count)
        .and_return(0)

      allow(TestRunner).to receive_message_chain(:available, :to_a)
        .and_return([], test_runners)
    end

    it "makes the assignments" do
      expect { test_suite_run.start! }
        .to change(TestRunnerAssignment, :count).by(2)
    end
  end

  context "there are no available test runners" do
    before do
      allow(TestRunner).to receive(:provision) do
        create(:test_runner) do |test_runner|
          test_runner.test_runner_events.create!(type: :ready_signal_received)
        end
      end
    end

    it "makes the assignments anyway" do
      expect { test_suite_run.start! }
        .to change(TestRunnerAssignment, :count).by(2)
    end
  end

  context "there are available test runners" do
    before do
      2.times do
        create(:test_runner) do |test_runner|
          test_runner.test_runner_events.create!(type: :ready_signal_received)
        end
      end
    end

    it "does not add test runners" do
      expect { test_suite_run.start! }
        .not_to change(TestRunner, :count)
    end
  end
end
