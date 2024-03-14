require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "'nothing here yet' message" do
    context "job info is present" do
      it "shows the info" do
        job = create(:job)
        result = helper.job_container("system_logs", job) do
          "Build machine ready"
        end

        expect(result).not_to include("Nothing here yet")
      end
    end

    context "job info is not present" do
      it "shows a 'nothing here yet' message" do
        job = create(:job)
        result = helper.job_container("system_logs", job) { "" }

        expect(result).to include("Nothing here yet")
      end
    end
  end
end
