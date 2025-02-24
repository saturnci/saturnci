require "rails_helper"

describe "Navigation", type: :system do
  context "starting on a runner that's not the first runner" do
    describe "clicking a subnav link" do
      let!(:build) { create(:build) }

      let!(:run_1) { create(:run, build:, order_index: 1) }
      let!(:run_2) { create(:run, build:, order_index: 2) }

      before do
        create(:runner_system_log, run: run_2, content: "runner 2 system logs")
        login_as(build.project.user)
      end

      it "does not change which runner you're on" do
        visit run_path(run_2, "test_output")
        click_on "System Logs"
        expect(page).to have_content("runner 2 system logs")
      end
    end
  end
end
