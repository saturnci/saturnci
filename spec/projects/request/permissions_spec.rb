require "rails_helper"

describe "Project permissions", type: :request do
  let!(:build) { create(:build) }
  let!(:project) { build.project }

  describe "GET project" do
    context "not signed in" do
      it "gives a 404" do
        get project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "one's own project" do
      before do
        login_as(project.user, scope: :user)
      end

      it "gives a 302" do
        get project_path(project)
        expect(response).to have_http_status(:found)
      end
    end

    context "somebody else's project" do
      before do
        login_as(create(:user), scope: :user)
      end

      it "gives a 404" do
        get project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
