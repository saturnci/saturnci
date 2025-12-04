require "rails_helper"

describe "Delete test suite run", type: :system do
  let!(:run) { create(:run, :with_worker) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(run.test_suite_run.repository.user)
  end

  context "runner still exists on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.worker.cloud_id}").to_return(status: 200)
    end

    context "branch is only branch" do
      it "removes the test suite run" do
        visit repository_test_suite_run_path(run.test_suite_run.repository, run.test_suite_run)
        click_on "Delete"
        expect(page).not_to have_content(run.test_suite_run.commit_hash)
      end
    end

    context "deleted test suite run is not the only test suite run" do
      let!(:other_test_suite_run) do
        create(:test_suite_run, :with_run, repository: run.test_suite_run.repository)
      end

      before do
        visit repository_test_suite_run_path(run.test_suite_run.repository, run.test_suite_run)
        click_on "Delete"
      end

      it "removes the deleted test suite run" do
        expect(page).not_to have_content(run.test_suite_run.commit_hash)
      end

      it "does not remove the other test suite run" do
        expect(page).to have_content(other_test_suite_run.commit_hash)
      end
    end

    context "test suite run is finished" do
      before do
        run.finish!
      end

      it "still works" do
        visit repository_test_suite_run_path(run.test_suite_run.repository, run.test_suite_run)
        click_on "Delete"
        expect(page).not_to have_content(run.test_suite_run.commit_hash)
        expect(page).to have_content("SaturnCI")
      end
    end
  end

  context "runner does not still exist on Digital Ocean" do
    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.worker.cloud_id}").to_return(status: 404)
    end

    it "removes the test suite run" do
      visit repository_test_suite_run_path(run.test_suite_run.repository, run.test_suite_run)
      click_on "Delete"
      expect(page).not_to have_content(run.test_suite_run.commit_hash)
    end
  end
end
