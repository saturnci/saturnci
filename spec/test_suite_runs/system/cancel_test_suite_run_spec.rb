require "rails_helper"

describe "Cancel test suite run", type: :system do
  let!(:task) { create(:task) }
  let!(:worker) { create(:worker) }
  let!(:worker_assignment) { create(:worker_assignment, task:, worker:) }

  before do
    allow(Nova).to receive(:delete_k8s_job)
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(task.test_suite_run.repository.user)
  end

  it "sets the status to 'Cancelled'" do
    visit run_path(task, "system_logs")

    click_on "Cancel"
    expect(page).to have_content("Cancelled")
  end
end
