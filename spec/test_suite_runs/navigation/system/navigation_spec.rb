require "rails_helper"

describe "Navigation", type: :system do
  context "starting on a worker that's not the first worker" do
    describe "clicking a subnav link" do
      let!(:test_suite_run) { create(:test_suite_run) }

      let!(:task_1) { create(:task, test_suite_run:, order_index: 1) }
      let!(:task_2) { create(:task, test_suite_run:, order_index: 2) }

      before do
        create(:runner_system_log, task: task_2, content: "worker 2 system logs")
        login_as(test_suite_run.project.user)
      end

      it "does not change which worker you're on" do
        visit run_path(task_2, "events")
        click_on "System Logs"
        expect(page).to have_content("worker 2 system logs")
      end
    end
  end

  context "visiting via task_path" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task_1) { create(:task, test_suite_run:, order_index: 1) }
    let!(:task_2) { create(:task, test_suite_run:, order_index: 2) }

    before do
      login_as(test_suite_run.project.user)
    end

    it "shows the correct worker tab as active" do
      visit task_path(task_2, "system_logs")
      expect(page).to have_css(".run-menu a.active", text: task_2.name)
    end
  end
end
