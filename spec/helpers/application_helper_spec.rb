require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "waiting message" do
    context "run info is present" do
      it "shows the info" do
        run = create(:run)
        result = helper.run_container("system_logs", run) do
          "Build machine ready"
        end

        expect(result).not_to include("Waiting")
      end
    end

    context "run info is not present" do
      it "shows a waiting message" do
        run = create(:run)
        result = helper.run_container("system_logs", run) { "" }

        expect(result).to include("Waiting")
      end
    end
  end
end
