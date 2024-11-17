require "rails_helper"

RSpec.describe "one failing job" do
  let!(:build) { create(:build) }

  let!(:passing_job) do
    create(:job, build:, order_index: 0)
  end

  let!(:failing_job) do
    create(:job, build:, order_index: 1, test_report: "failed")
  end

  describe "build status" do
    it "gets set to 'Failed'" do
      passing_job.finish!
      failing_job.finish!
      expect(build.reload.cached_status).to eq("Failed")
    end
  end
end
