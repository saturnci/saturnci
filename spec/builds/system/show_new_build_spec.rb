require "rails_helper"

describe "Show new build", type: :system do
  let!(:build) { create(:build) }

  before do
    login_as(build.project.user, scope: :user)
    visit project_path(build.project)
  end

  context "a new build gets created" do
    let!(:new_build) { create(:build, project: build.project) }

    it "shows the new build" do
      new_build.broadcast

      within ".build-list" do
        expect(page).to have_content(new_build.commit_hash, count: 1)
      end
    end

    context "the page gets loaded before the broadcast occurs" do
      it "does not show the new build twice" do
        visit project_path(build.project)
        new_build.broadcast

        within ".build-list" do
          expect(page).to have_content(new_build.commit_hash, count: 1)
        end
      end
    end
  end

  context "a different user's build" do
    it "does not show the new build" do
      new_build = create(:build, project: create(:project))
      new_build.broadcast
      expect(page).not_to have_content(new_build.commit_hash)
    end
  end

  context "build gets not just created but started" do
    let!(:new_build) { create(:build, project: build.project) }
    let!(:run) { create(:run, build: new_build) }

    # This simulates the runner request taking a while
    let!(:runner_request_delay) { sleep(5) }

    it "shows the new build" do
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
