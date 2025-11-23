require "rails_helper"

describe "Status filtering", type: :system do
  let!(:passed_run) { create(:run, :passed) }

  let!(:failed_run) do
    create(
      :run,
      :failed,
      build: create(:build, repository: passed_run.build.repository)
    ).finish!
  end

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(passed_run.build.repository.user)
    visit run_path(passed_run, "test_output")
    click_on "Filters"
  end

  context "passed builds only" do
    before do
      check "Passed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the passed build" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_run.build.commit_hash)
      end
    end

    it "does not include the failed build" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(failed_run.build.commit_hash)
      end
    end
  end

  context "failed builds only" do
    before do
      check "Failed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the failed build" do
      within ".test-suite-run-list" do
        expect(page).to have_content(failed_run.build.commit_hash)
      end
    end

    it "does not include the passed build" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(passed_run.build.commit_hash)
      end
    end
  end

  context "passed and failed builds" do
    before do
      check "Passed"
      check "Failed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the failed build" do
      within ".test-suite-run-list" do
        expect(page).to have_content(failed_run.build.commit_hash)
      end
    end

    it "includes the passed build" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_run.build.commit_hash)
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
        expect(page).not_to have_content(failed_run.build.commit_hash)
      end

      expect(page).to have_checked_field("Passed")
    end

    it "'Failed' stays checked after form submission" do
      check "Failed"
      click_on "Apply"
      click_on "Filters"

      # to prevent race condition
      within ".test-suite-run-list" do
        expect(page).not_to have_content(passed_run.build.commit_hash)
      end

      expect(page).to have_checked_field("Failed")
    end
  end

  context "starting from build overview page" do
    let!(:test_case_run) do
      create(:test_case_run, run: failed_run)
    end

    before do
      visit repository_build_path(failed_run.build.repository, failed_run.build)
      click_on "Filters"
      check "Passed"
      click_on "Apply"
      click_on "Filters"
    end

    it "includes the passed build" do
      within ".test-suite-run-list" do
        expect(page).to have_content(passed_run.build.commit_hash)
      end
    end

    it "does not include the failed build" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content(failed_run.build.commit_hash)
      end
    end
  end
end
