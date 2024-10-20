require "rails_helper"

RSpec.describe Job, type: :model do
  let!(:job) { create(:job) }

  before do
    fake_job_machine_request = double("JobMachineRequest")
    allow(job).to receive(:job_machine_request).and_return(fake_job_machine_request)
    allow(fake_job_machine_request).to receive(:create!)
  end

  describe "#start!" do
    it "creates a new job_event with type job_machine_requested" do
      expect { job.start! }
        .to change { JobEvent.where(type: "job_machine_requested").count }.by(1)
    end
  end

  describe "#finished?" do
    context "it has a job_finished event" do
      before do
        job.job_events.create!(type: "job_finished")
      end

      it "returns true" do
        expect(job).to be_finished
      end
    end

    context "it does not have a job_finished event" do
      it "returns false" do
        expect(job).not_to be_finished
      end
    end
  end

  describe "#duration" do
    it "gets rounded to the nearest whole number" do
      allow(job).to receive(:ended_at).and_return(Time.zone.parse("2024-07-28 13:17:19 UTC"))
      allow(job).to receive(:started_at).and_return(Time.zone.parse("2024-07-28 13:16:18.376176 UTC"))

      expect(job.duration).to eq(61)
    end
  end

  describe "#finish!" do
    let!(:other_job) do
      create(:job, build: job.build, order_index: 2)
    end

    context "it is not the last job to finish" do
      it "does not update its build's cached status" do
        expect { job.finish! }.not_to change {
          job.build.reload.cached_status
        }
      end
    end

    context "it is the last job to finish" do
      before { other_job.finish! }

      it "updates its build's cached status" do
        expect { job.finish! }.to change {
          job.build.reload.cached_status
        }.from(nil).to("Passed")
      end
    end
  end

  describe "#exit_code" do
    before do
      job.update!(test_report: "Script done on 2024-10-20 13:41:25+00:00 [COMMAND_EXIT_CODE=\"1\"]")
    end

    it "has an exit code of 1" do
      expect(job.exit_code).to eq(1)
    end
  end
end
