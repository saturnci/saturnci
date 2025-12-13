require "rails_helper"

describe "Status filtering", type: :system do
  let!(:passed_task) { create(:task, :passed) }

  let!(:failed_task) do
    create(
      :task,
      :failed,
      test_suite_run: create(:test_suite_run, repository: passed_task.test_suite_run.repository)
    ).finish!
  end

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(passed_task.test_suite_run.repository.user)
    visit task_path(passed_task, "system_logs")
    click_on "Filters"
  end

  context "passed test suite runs only" do
    before do
      check "Passed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the passed test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_task.test_suite_run.commit_hash)
      end
    end

    it "does not include the failed test suite run" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(failed_task.test_suite_run.commit_hash)
      end
    end
  end

  context "failed test suite runs only" do
    before do
      check "Failed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the failed test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(failed_task.test_suite_run.commit_hash)
      end
    end

    it "does not include the passed test suite run" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(passed_task.test_suite_run.commit_hash)
      end
    end
  end

  context "passed and failed test suite runs" do
    before do
      check "Passed"
      check "Failed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the failed test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(failed_task.test_suite_run.commit_hash)
      end
    end

    it "includes the passed test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_task.test_suite_run.commit_hash)
      end
    end
  end

  describe "selected checkboxes" do
    it "'Passed' stays checked after form submission" do
      check "Passed"
      click_on "Apply"
      click_on "Filters"

      # to prevent race condition
      within ".test-suite-run-list" do
        expect(page).not_to have_content(failed_task.test_suite_run.commit_hash)
      end

      expect(page).to have_checked_field("Passed")
    end

    it "'Failed' stays checked after form submission" do
      check "Failed"
      click_on "Apply"
      click_on "Filters"

      # to prevent race condition
      within ".test-suite-run-list" do
        expect(page).not_to have_content(passed_task.test_suite_run.commit_hash)
      end

      expect(page).to have_checked_field("Failed")
    end
  end

  context "starting from test suite run overview page" do
    let!(:test_case_run) do
      create(:test_case_run, run: failed_task)
    end

    before do
      visit task_path(failed_task, "system_logs")
      click_on "Filters"
      check "Passed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the passed test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_task.test_suite_run.commit_hash)
      end
    end

    it "does not include the failed test suite run" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(failed_task.test_suite_run.commit_hash)
      end
    end
  end
end
