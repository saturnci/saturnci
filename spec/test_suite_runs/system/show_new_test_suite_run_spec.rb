require "rails_helper"

describe "Show new test suite run", type: :system do
  let!(:build) { create(:build) }

  before do
    login_as(build.project.user, scope: :user)
    visit project_path(build.project)
  end

  context "two test suite runs, two projects" do
    let!(:other_project) do
      create(:project, user: build.project.user)
    end

    let!(:new_build) { create(:build, project: build.project) }
    let!(:other_project_new_build) { create(:build, project: other_project) }

    before do
      new_build.broadcast
      other_project_new_build.broadcast
    end

    it "shows the new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_build.commit_hash, count: 1)
      end
    end

    it "does not show the other project's new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(new_build.commit_hash) # to prevent race condition
        expect(page).not_to have_content(other_project_new_build.commit_hash)
      end
    end
  end

  context "a new build gets created" do
    let!(:new_build) { create(:build, project: build.project) }

    it "shows the new build" do
      new_build.broadcast

      within ".test-suite-run-list" do
        expect(page).to have_content(new_build.commit_hash, count: 1)
      end
    end

    context "the page gets loaded before the broadcast occurs" do
      it "does not show the new build twice" do
        visit project_path(build.project)
        new_build.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_build.commit_hash, count: 1)
        end
      end
    end

    context "broadcast occurs twice" do
      it "only shows the new build once" do
        visit project_path(build.project)

        new_build.broadcast

        within ".test-suite-run-list" do
          expect(page).to have_content(new_build.commit_hash, count: 1)
        end
      end
    end
  end

  context "a different user's test suite run" do
    it "does not show the new test suite run" do
      new_build = create(:build, project: create(:project))
      new_build.broadcast
      expect(page).not_to have_content(new_build.commit_hash)
    end
  end

  context "test suite run gets not just created but started" do
    let!(:new_build) { create(:build, project: build.project) }
    let!(:run) { create(:run, build: new_build) }

    # This simulates the runner request taking a while
    let!(:runner_request_delay) { sleep(5) }

    it "shows the new test suite run" do
      runner_request = double("RunnerRequest")
      allow(runner_request).to receive(:execute!).and_return(runner_request_delay)

      allow(run).to receive(:runner_request).and_return(runner_request)
      allow(new_build).to receive(:runs_to_use).and_return([run])

      new_build.start!
      new_build.broadcast
      expect(page).to have_content(new_build.commit_hash)
    end
  end
end
