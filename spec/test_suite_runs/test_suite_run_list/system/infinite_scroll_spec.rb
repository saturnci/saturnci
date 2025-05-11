require "rails_helper"

describe "Test suite run infinite scroll", type: :system do
  include ScrollingHelper

  let!(:project) { create(:project) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
  end

  describe "large number of test suite runs" do
    let!(:builds) do
      create_list(:build, 100, project:)
    end

    before do
      login_as(project.user)
      visit project_build_path(project, builds.first)
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
    let!(:oldest_build) do
      create(:build, project:, commit_message: "21st test suite run")
    end

    let!(:builds) do
      create_list(:build, 20, project:)
    end

    before do
      login_as(project.user, scope: :user)
      visit project_build_path(project, builds.first)
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
        create(:run, :failed, build: create(:build, project:))
      end
    end

    let!(:passed_runs) do
      30.times.map do
        create(:run, :passed, build: create(:build, project:))
      end
    end

    before do
      Build.all.each(&:status) # to prime cache

      login_as(project.user)
      visit project_build_path(project, passed_runs.first.build)
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
