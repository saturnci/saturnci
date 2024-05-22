require "rails_helper"

describe "Delete build", type: :system do
  let!(:job) { create(:job) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  context "job machine still exists on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{job.job_machine_id}").to_return(status: 200)
    end

    context "branch is only branch" do
      it "removes the build" do
        visit project_build_path(id: job.build.id, project_id: job.build.project.id)
        click_on "Delete"
        expect(page).not_to have_content(job.build.commit_hash)
      end
    end

    context "deleted build is not the only build" do
      let!(:other_build) do
        create(:build, :with_job, project: job.build.project)
      end

      before do
        visit project_build_path(id: job.build.id, project_id: job.build.project.id)
        click_on "Delete"
      end

      it "removes the deleted build" do
        expect(page).not_to have_content(job.build.commit_hash)
      end

      it "does not remove the other build" do
        expect(page).to have_content(other_build.commit_hash)
      end
    end
  end

  context "job machine does not still exist on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{job.job_machine_id}").to_return(status: 404)
    end

    it "removes the build" do
      visit project_build_path(id: job.build.id, project_id: job.build.project.id)
      click_on "Delete"
      expect(page).not_to have_content(job.build.commit_hash)
    end
  end
end
