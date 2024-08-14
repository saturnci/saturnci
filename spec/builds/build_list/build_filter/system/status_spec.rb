require "rails_helper"

describe "Status filtering", type: :system do
  let!(:passed_job) { create(:job).finish! }

  let!(:failed_job) do
    create(
      :job,
      build: create(:build, project: passed_job.build.project)
    ).finish!
  end

  before do
    passed_job.build.update!(cached_status: "Passed")
    failed_job.build.update!(cached_status: "Failed")

    login_as(passed_job.build.project.user, scope: :user)
    visit job_path(passed_job, "test_output")
  end

  context "passed builds only" do
    before do
      check "Passed"
      click_on "Apply"
    end

    it "includes the passed build" do
      within ".build-list" do
        expect(page).to have_content(passed_job.build.commit_hash)
      end
    end

    it "does not include the failed build" do
      within ".build-list" do
        expect(page).not_to have_content(failed_job.build.commit_hash)
      end
    end
  end

  context "failed builds only" do
    before do
      check "Failed"
      click_on "Apply"
    end

    it "includes the failed build" do
      within ".build-list" do
        expect(page).to have_content(failed_job.build.commit_hash)
      end
    end

    it "does not include the passed build" do
      within ".build-list" do
        expect(page).not_to have_content(passed_job.build.commit_hash)
      end
    end
  end

  context "passed and failed builds" do
    before do
      check "Passed"
      check "Failed"
      click_on "Apply"
    end

    it "includes the failed build" do
      within ".build-list" do
        expect(page).to have_content(failed_job.build.commit_hash)
      end
    end

    it "includes the passed build" do
      within ".build-list" do
        expect(page).to have_content(passed_job.build.commit_hash)
      end
    end
  end

  describe "selected checkboxes" do
    it "'Passed' stays checked after form submission" do
      check "Passed"
      click_on "Apply"

      # to prevent race condition
      within ".build-list" do
        expect(page).not_to have_content(failed_job.build.commit_hash)
      end

      expect(page).to have_checked_field("Passed")
    end

    it "'Failed' stays checked after form submission" do
      check "Failed"
      click_on "Apply"

      # to prevent race condition
      within ".build-list" do
        expect(page).not_to have_content(passed_job.build.commit_hash)
      end

      expect(page).to have_checked_field("Failed")
    end
  end
end
