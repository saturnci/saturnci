require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "waiting message" do
    context "job info is present" do
      it "shows the info" do
        job = create(:job)
        result = helper.job_container("system_logs", job) do
          "Build machine ready"
        end

        expect(result).not_to include("Waiting")
      end
    end

    context "job info is not present" do
      it "shows a waiting message" do
        job = create(:job)
        result = helper.job_container("system_logs", job) { "" }

        expect(result).to include("Waiting")
      end
    end
  end
end
