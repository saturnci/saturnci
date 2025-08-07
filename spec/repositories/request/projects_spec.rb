require "rails_helper"

describe "Projects", type: :request do
  describe "GET project" do
    context "when there is a build" do
      let!(:build) { create(:build) }

      before do
        login_as(build.project.user)
      end

      it "redirects to the build" do
        get project_path(build.project)

        expect(response).to redirect_to(TestSuiteRunLinkPath.new(build).value)
      end
    end

    context "when there is no build" do
      let!(:project) { create(:project) }

      before do
        login_as(project.user, scope: :user)

        allow(TestSuiteRunFromCommitFactory).to receive(:most_recent_commit).and_return(
          {
            "sha" => "d9e65e719b3fffae853d6264485d3f0467b3d8a3",
            "commit" => {
              "author" => {
                "name" => "Jason Swett",
              },
              "message" => "Change stuff.",
            }
          }
        )
      end

      context "there have never been builds before" do
        it "creates a build" do
          expect {
            get project_path(project)
          }.to change(Build, :count).by(1)
        end
      end

      context "there are builds for other projects" do
        before { create(:build) }

        it "creates a build" do
          expect {
            get project_path(project)
          }.to change(Build, :count).by(1)
        end
      end

      context "there have been builds before" do
        before do
          create(:build, project:).destroy
        end

        it "does not create a build" do
          expect {
            get project_path(project)
          }.not_to change(Build, :count)
        end
      end
    end
  end
end
