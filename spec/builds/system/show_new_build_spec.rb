require "rails_helper"

describe "Show new build", type: :system do
  let!(:build) { create(:build) }

  before do
    login_as(build.project.user, scope: :user)
    visit project_path(build.project)
  end

  context "a new build gets created" do
    it "shows the new build" do
      new_build = create(:build, project: build.project)
      new_build.broadcast
      expect(page).to have_content(new_build.commit_hash)
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
