require "rails_helper"

RSpec.describe Build, type: :model do
  describe "#duration" do
    let!(:build) { create(:build) }

    context "no runs" do
      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "one run finished, the other not finished yet" do
      before do
        finished_run = create(:run, build: build, order_index: 1)
        allow(finished_run).to receive(:duration).and_return(5)

        unfinished_run = create(:run, build: build, order_index: 2)
        allow(unfinished_run).to receive(:duration).and_return(nil)

        allow(build).to receive(:runs).and_return([finished_run, unfinished_run])
      end

      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "two finished runs" do
      before do
        shorter_run = create(:run, build: build, order_index: 1)
        allow(shorter_run).to receive(:duration).and_return(5)

        longer_run = create(:run, build: build, order_index: 2)
        allow(longer_run).to receive(:duration).and_return(7)

        allow(build).to receive(:runs).and_return([shorter_run, longer_run])
      end

      it "returns the longer of the two runs" do
        expect(build.duration).to eq(7)
      end
    end
  end

  describe "#start!" do
    let!(:run) { create(:run) }
    let!(:build) { run.build }

    before do
      fake_runner_request = double("RunnerRequest")
      allow(run).to receive(:runner_request).and_return(fake_runner_request)
      allow(fake_runner_request).to receive(:create!)
      allow(build).to receive(:runs_to_use).and_return([run])
    end

    it "creates a new job_event with type runner_requested" do
      expect { build.start! }
        .to change { JobEvent.where(type: "runner_requested").count }.by(1)
    end
  end

  describe "#cancel!" do
    let!(:run) { create(:run) }

    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.job_machine_id}").to_return(status: 200)
    end

    it "sets the status to 'Cancelled'" do
      run.build.cancel!
      expect(run.build.reload.status).to eq("Cancelled")
    end
  end
end
