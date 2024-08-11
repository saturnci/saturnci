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

  describe "#status" do
    context "there's no report yet" do
      it "returns 'Running'" do
        expect(job.status).to eq("Running")
      end
    end

    context "report is empty" do
      it "returns 'Running'" do
        job.update!(test_report: "")
        expect(job.status).to eq("Running")
      end
    end

    context "report is success" do
      it "returns 'Passed'" do
        job.update!(test_report: success)
        job.job_events.create!(type: "job_finished")
        expect(job.status).to eq("Passed")
      end
    end

    context "report is failure" do
      it "returns 'Failed'" do
        job.update!(test_report: failure)
        job.job_events.create!(type: "job_finished")
        expect(job.status).to eq("Failed")
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
        }.from(nil).to("passed")
      end
    end
  end

  def success
    <<~RESULTS
example_id                                                 | status | run_time        |
---------------------------------------------------------- | ------ | --------------- |
./spec/models/github_token_spec.rb[1:2:1]                  | passed | 0.00288 seconds |
./spec/rebuilds_spec.rb[1:1:1]                             | passed | 0.04704 seconds |
./spec/sign_up_spec.rb[1:1:1]                              | passed | 0.1331 seconds  |
./spec/test_spec.rb[1:1]                                   | passed | 0.00798 seconds |
    RESULTS
  end

  def failure
    <<~RESULTS
example_id                                                 | status | run_time        |
---------------------------------------------------------- | ------ | --------------- |
./spec/models/github_token_spec.rb[1:2:1]                  | passed | 0.00288 seconds |
./spec/rebuilds_spec.rb[1:1:1]                             | passed | 0.04704 seconds |
./spec/sign_up_spec.rb[1:1:1]                              | passed | 0.1331 seconds  |
./spec/test_spec.rb[1:1]                                   | failed | 0.00798 seconds |
    RESULTS
  end
end
