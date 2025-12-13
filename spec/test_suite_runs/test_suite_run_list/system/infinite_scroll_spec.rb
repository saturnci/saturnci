require "rails_helper"

describe "Test suite run infinite scroll", type: :system do
  include ScrollingHelper

  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
  end

  describe "large number of test suite runs" do
    let!(:test_suite_runs) do
      create_list(:test_suite_run, 100, repository:)
    end

    before do
      login_as(repository.user)
      visit repository_test_suite_run_path(repository, test_suite_runs.first)
    end

    it "initially only shows the first 20 test suite runs" do
      expect(page).to have_css(".test-suite-run-link", count: 20)
    end

    describe "scrolling to the bottom" do
      before do
        scroll_to_bottom(".test-suite-run-list")
        sleep(0.5) # wait for additional records to load
      end

      it "shows 20 more test suite runs" do
        expect(page).to have_css(".test-suite-run-link", count: 40)
      end
    end

    describe "scrolling to the bottom twice" do
      before do
        scroll_to_bottom(".test-suite-run-list")
        sleep(1) # wait for additional records to load
        scroll_to_bottom(".test-suite-run-list")
        sleep(1) # wait for additional records to load
      end

      it "shows 20 more test suite runs" do
        expect(page).to have_css(".test-suite-run-link", count: 60)
      end
    end

    it "shows the total number of test suite runs" do
      expect(page).to have_content("100 test suite runs")
    end
  end

  describe "chunking" do
    let!(:oldest_test_suite_run) do
      create(:test_suite_run, repository:, commit_message: "21st test suite run")
    end

    let!(:test_suite_runs) do
      create_list(:test_suite_run, 20, repository:)
    end

    before do
      login_as(repository.user, scope: :user)
      visit repository_test_suite_run_path(repository, test_suite_runs.first)
    end

    context "before scrolling to the bottom" do
      it "does not show the 21st test suite run" do
        expect(page).not_to have_content("21st test suite run")
      end
    end

    context "after scrolling to the bottom" do
      before do
        scroll_to_bottom(".test-suite-run-list")
        sleep(0.5) # wait for additional record to load
      end

      it "shows the 21st test suite run" do
        expect(page).to have_content("21st test suite run")
      end
    end
  end

  context "when a filter is applied (e.g. 'passed')" do
    let!(:failed_runs) do
      10.times.map do
        create(:run, :failed, test_suite_run: create(:test_suite_run, repository:))
      end
    end

    let!(:passed_runs) do
      30.times.map do
        create(:run, :passed, test_suite_run: create(:test_suite_run, repository:))
      end
    end

    before do
      TestSuiteRun.all.each(&:status) # to prime cache

      login_as(repository.user)
      visit task_path(passed_runs.first, "system_logs")
      click_on "Filters"
      check "Passed"
      click_on "Apply"
    end

    it "limits the list to the 30 passed test suite runs" do
      expect(page).to have_content("30 test suite runs")
    end

    context "after scrolling to the bottom" do
      before do
        expect(page).to have_css(".test-suite-run-link", count: 20)
        sleep(0.5)
        scroll_to_bottom(".test-suite-run-list")
      end

      it "shows the 10 additional passed test suite runs but not any of the failed test suite runs" do
        expect(page).to have_css(".test-suite-run-link", count: 30)
      end
    end
  end
end
