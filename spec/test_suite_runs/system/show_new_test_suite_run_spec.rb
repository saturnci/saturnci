require "rails_helper"

describe "Show new test suite run", type: :system do
  let!(:test_suite_run) { create(:build) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(test_suite_run.repository.user)
    visit repository_path(test_suite_run.repository)
  end

  context "two test suite runs, two repositories" do
    let!(:other_repository) do
      create(:repository, github_account: create(:github_account, user: test_suite_run.repository.user))
    end

    let!(:new_test_suite_run) { create(:build, repository: test_suite_run.repository) }
    let!(:other_repository_new_test_suite_run) { create(:build, repository: other_repository) }

    before do
      new_test_suite_run.broadcast
      other_repository_new_test_suite_run.broadcast
    end

    it "shows the new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
      end
    end

    it "does not show the other repository's new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_test_suite_run.commit_hash) # to prevent race condition
        expect(page).not_to have_content(other_repository_new_test_suite_run.commit_hash)
      end
    end
  end

  context "a new test suite run gets created" do
    let!(:new_test_suite_run) { create(:build, repository: test_suite_run.repository) }

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
        visit repository_path(test_suite_run.repository)
        new_test_suite_run.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
        end
      end
    end

    context "broadcast occurs twice" do
      it "only shows the new test suite run once" do
        visit repository_path(test_suite_run.repository)

        new_test_suite_run.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_test_suite_run.commit_hash, count: 1)
        end
      end
    end
  end

  context "a different user's test suite run" do
    it "does not show the new test suite run" do
      new_test_suite_run = create(:build, repository: create(:repository))
      new_test_suite_run.broadcast
      expect(page).not_to have_content(new_test_suite_run.commit_hash)
    end
  end

  context "test suite run gets not just created but started" do
    let!(:new_test_suite_run) do
      create(:build, repository: test_suite_run.repository)
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
