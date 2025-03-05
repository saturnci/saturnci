require "rails_helper"

RSpec.describe "one failing run" do
  let!(:build) { create(:build) }

  let!(:passing_run) do
    create(:run, build:, order_index: 0)
  end

  let!(:failing_run) do
    create(:run, :failed, build:, order_index: 1)
  end

  describe "build status" do
    it "gets set to 'Failed'" do
      passing_run.finish!
      failing_run.finish!
      expect(build.reload.cached_status).to eq("Failed")
    end
  end
end
