require "rails_helper"

describe Run, type: :model do
  let!(:run) { create(:run) }

  before do
    fake_runner_request = double("RunnerRequest")
    allow(run).to receive(:runner_request).and_return(fake_runner_request)
    allow(fake_runner_request).to receive(:execute!)
  end

  describe "#start!" do
    it "creates a new run_event with type runner_requested" do
      expect { run.start! }
        .to change { run.run_events.where(type: "runner_requested").count }.by(1)
    end
  end

  describe "#cancel!" do
    before do
      allow(run).to receive(:delete_runner)
    end

    it "creates a new run_event with type run_cancelled" do
      expect { run.cancel! }
        .to change { run.run_events.where(type: "run_cancelled").count }.by(1)
    end

    it "sets the status to 'Cancelled'" do
      run.cancel!
      expect(run.reload.status).to eq("Cancelled")
    end

    it "sets the test output to 'Run cancelled'" do
      run.cancel!
      expect(run.reload.test_output).to eq("Run cancelled")
    end
  end

  describe "#finished?" do
    context "it has an exit code" do
      before do
        run.update!(exit_code: 0)
      end

      it "returns true" do
        expect(run).to be_finished
      end
    end

    context "it does not have an exit code" do
      it "returns false" do
        expect(run).not_to be_finished
      end
    end
  end

  describe "#duration" do
    it "gets rounded to the nearest whole number" do
      allow(run).to receive(:ended_at).and_return(Time.zone.parse("2024-07-28 13:17:19 UTC"))
      allow(run).to receive(:started_at).and_return(Time.zone.parse("2024-07-28 13:16:18.376176 UTC"))

      expect(run.duration).to eq(61)
    end
  end

  describe "#finish!" do
    let!(:other_run) do
      create(:run, build: run.build, order_index: 2)
    end

    context "it is the last run to finish" do
      before { other_run.finish! }

      it "updates its test suite run's status" do
        expect { run.finish! }.to change { run.test_suite_run.status }
          .from("Running").to("Failed")
      end
    end

    context "it is not the last run to finish" do
      it "does not update its test suite run's status" do
        expect { run.finish! }.not_to change { run.test_suite_run.status }
      end
    end
  end

  describe "#exit_code" do
    context "test_output contains COMMAND_EXIT_CODE" do
      before do
        run.update!(test_output: "Script done on 2024-10-20 13:41:25+00:00 [COMMAND_EXIT_CODE=\"0\"]")
      end

      it "gets saved upon finish" do
        expect { run.finish! }.to change { run.reload.exit_code }.from(nil).to(0)
      end
    end

    context "test_output contains COMMAND_EXIT_CODE with no quotes" do
      before do
        run.update!(test_output: "Script done on 2023-11-05 14:10:32+00:00 [COMMAND_EXIT_CODE=0]\n")
      end

      it "gets saved upon finish" do
        expect { run.finish! }.to change { run.reload.exit_code }.from(nil).to(0)
      end
    end

    context "test_output does not contain COMMAND_EXIT_CODE" do
      it "defaults to 1" do
        expect { run.finish! }.to change { run.reload.exit_code }.from(nil).to(1)
      end
    end
  end

  describe "updating exit code" do
    it "updates build updated_at" do
      expect {
        run.update!(exit_code: 0)
      }.to change { run.build.reload.updated_at }
    end
  end
end
