require "rails_helper"

describe "Show new test suite run", type: :system do
  let!(:test_suite_run) { create(:build) }

  before do
    login_as(test_suite_run.project.user)
    visit project_path(test_suite_run.project)
  end

  context "two test suite runs, two projects" do
    let!(:other_project) do
      create(:project, github_account: create(:github_account, user: test_suite_run.project.user))
    end

    let!(:new_test_suite_run) { create(:build, project: test_suite_run.project) }
    let!(:other_project_new_test_suite_run) { create(:build, project: other_project) }

    before do
      new_test_suite_run.broadcast
      other_project_new_test_suite_run.broadcast
    end

    it "shows the new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
      end
    end

    it "does not show the other project's new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_test_suite_run.commit_hash) # to prevent race condition
        expect(page).not_to have_content(other_project_new_test_suite_run.commit_hash)
      end
    end
  end

  context "a new test suite run gets created" do
    let!(:new_test_suite_run) { create(:build, project: test_suite_run.project) }

    it "shows the new test suite run" do
      within ".test-suite-run-list" do
        # To prevent race condition
        expect(page).to have_content(test_suite_run.commit_hash, count: 1)

        new_test_suite_run.broadcast
        expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
      end
    end

    context "the page gets loaded before the broadcast occurs" do
      it "does not show the new test suite run twice" do
        visit project_path(test_suite_run.project)
        new_test_suite_run.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
        end
      end
    end

    context "broadcast occurs twice" do
      it "only shows the new test suite run once" do
        visit project_path(test_suite_run.project)

        new_test_suite_run.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
        end
      end
    end
  end

  context "a different user's test suite run" do
    it "does not show the new test suite run" do
      new_test_suite_run = create(:build, project: create(:project))
      new_test_suite_run.broadcast
      expect(page).not_to have_content(new_test_suite_run.commit_hash)
    end
  end

  context "test suite run gets not just created but started" do
    let!(:new_test_suite_run) do
      create(:build, project: test_suite_run.project)
    end

    let!(:run) do
      create(:run, build: new_test_suite_run, order_index: 2)
    end

    it "shows the new test suite run" do
      new_test_suite_run.broadcast
      expect(page).to have_content(new_test_suite_run.commit_hash)
    end
  end
end
