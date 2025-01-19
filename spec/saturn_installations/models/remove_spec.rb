require "rails_helper"

describe "Removing a Saturn Installation" do
  context "the project has more than zero runs" do
    let!(:run) { create(:run) }

    it "deletes any associated projects" do
      expect { run.build.project.saturn_installation.destroy }
        .to change { Project.exists?(run.build.project.id) }
        .from(true).to(false)
    end
  end
end
