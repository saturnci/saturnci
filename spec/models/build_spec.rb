require "rails_helper"

RSpec.describe Build, type: :model do
  describe "#duration" do
    let!(:build) { create(:build) }

    context "no jobs" do
      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "one job finished, the other not finished yet" do
      before do
        finished_job = create(:job, build: build, order_index: 1)
        allow(finished_job).to receive(:duration).and_return(5)

        unfinished_job = create(:job, build: build, order_index: 2)
        allow(unfinished_job).to receive(:duration).and_return(nil)

        allow(build).to receive(:jobs).and_return([finished_job, unfinished_job])
      end

      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "two finished jobs" do
      before do
        shorter_job = create(:job, build: build, order_index: 1)
        allow(shorter_job).to receive(:duration).and_return(5)

        longer_job = create(:job, build: build, order_index: 2)
        allow(longer_job).to receive(:duration).and_return(7)

        allow(build).to receive(:jobs).and_return([shorter_job, longer_job])
      end

      it "returns the longer of the two jobs" do
        expect(build.duration).to eq(7)
      end
    end
  end

  describe "#start!" do
    let!(:job) { create(:job) }
    let!(:build) { job.build }

    before do
      fake_job_machine_request = double("JobMachineRequest")
      allow(job).to receive(:job_machine_request).and_return(fake_job_machine_request)
      allow(fake_job_machine_request).to receive(:create!)
      allow(build).to receive(:jobs_to_use).and_return([job])
    end

    it "creates a new job_event with type job_machine_requested" do
      expect { build.start! }
        .to change { JobEvent.where(type: "job_machine_requested").count }.by(1)
    end
  end
end
