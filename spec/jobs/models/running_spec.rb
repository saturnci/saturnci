require "rails_helper"

RSpec.describe Job, type: :model do
  describe "#running" do
    let!(:running_job) do
      create(:job, test_report: nil)
    end

    let!(:finished_job) do
      create(:job) do |j|
        j.job_events.create!(type: "job_finished")
      end
    end

    it "by default includes the running job" do
      expect(Job.running).to include(running_job)
    end

    it "by default does not include the finished job" do
      expect(Job.running).not_to include(finished_job)
    end
  end

  context "two builds" do
    let!(:build_1) { create(:build) }
    let!(:build_2) { create(:build) }

    before do
      create(:job, build: build_1, order_index: 1)
      create(:job, build: build_1, order_index: 2)

      create(:job, build: build_2, order_index: 1)
      create(:job, build: build_2, order_index: 2)
    end

    it "groups by build" do
      expected_ids = [
        build_2.id,
        build_2.id,
        build_1.id,
        build_1.id,
      ]

      expect(Job.running.map(&:build_id)).to eq(expected_ids)
    end
  end
end
