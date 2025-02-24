require "rails_helper"

describe "Delete build", type: :system do
  let!(:run) { create(:run) }

  before do
    login_as(run.build.project.user)
  end

  context "runner still exists on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.runner_id}").to_return(status: 200)
    end

    context "branch is only branch" do
      it "removes the build" do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        click_on "Delete"
        expect(page).not_to have_content(run.build.commit_hash)
      end
    end

    context "deleted build is not the only build" do
      let!(:other_build) do
        create(:build, :with_run, project: run.build.project)
      end

      before do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        click_on "Delete"
      end

      it "removes the deleted build" do
        expect(page).not_to have_content(run.build.commit_hash)
      end

      it "does not remove the other build" do
        expect(page).to have_content(other_build.commit_hash)
      end
    end

    context "build is finished" do
      before do
        run.finish!
      end

      it "still works" do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        click_on "Delete"
        expect(page).not_to have_content(run.build.commit_hash)
        expect(page).to have_content("SaturnCI")
      end
    end
  end

  context "runner does not still exist on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.runner_id}").to_return(status: 404)
    end

    it "removes the build" do
      visit project_build_path(id: run.build.id, project_id: run.build.project.id)
      click_on "Delete"
      expect(page).not_to have_content(run.build.commit_hash)
    end
  end
end
