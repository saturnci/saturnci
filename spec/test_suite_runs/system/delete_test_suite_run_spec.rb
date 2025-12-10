require "rails_helper"

describe "Delete test suite run", type: :system do
  let!(:task) { create(:task) }
  let!(:worker) { create(:worker) }
  let!(:worker_assignment) { create(:worker_assignment, task:, worker:) }

  before do
    allow(Nova).to receive(:delete_k8s_job)
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(task.test_suite_run.repository.user)
  end

  it "removes the test suite run" do
    visit repository_test_suite_run_path(task.test_suite_run.repository, task.test_suite_run)
    click_on "Delete"
    expect(page).not_to have_content(task.test_suite_run.commit_hash)
  end

  context "deleted test suite run is not the only test suite run" do
    let!(:other_test_suite_run) do
      create(:test_suite_run, :with_run, repository: task.test_suite_run.repository)
    end

    before do
      visit repository_test_suite_run_path(task.test_suite_run.repository, task.test_suite_run)
      click_on "Delete"
    end

    it "removes the deleted test suite run" do
      expect(page).not_to have_content(task.test_suite_run.commit_hash)
    end

    it "does not remove the other test suite run" do
      expect(page).to have_content(other_test_suite_run.commit_hash)
    end
  end

  context "test suite run is finished" do
    before do
      task.finish!
    end

    it "still works" do
      visit repository_test_suite_run_path(task.test_suite_run.repository, task.test_suite_run)
      click_on "Delete"
      expect(page).not_to have_content(task.test_suite_run.commit_hash)
      expect(page).to have_content("SaturnCI")
    end
  end
end
