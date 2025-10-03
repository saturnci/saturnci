require "rails_helper"

describe "Removing a GitHub Account" do
  context "the project has more than zero runs" do
    let!(:run) { create(:run) }

    it "deletes any associated projects" do
      expect { run.test_suite_run.project.github_account.destroy }
        .to change { Project.exists?(run.test_suite_run.project.id) }
        .from(true).to(false)
    end
  end
end
