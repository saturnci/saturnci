require "rails_helper"

describe "Repository permissions", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }
  let!(:repository) { test_suite_run.repository }

  describe "GET repository" do
    context "not signed in" do
      it "gives a 404" do
        get project_path(repository)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "one's own repository" do
      before do
        login_as(repository.user)
      end

      it "gives a 302" do
        get project_path(repository)
        expect(response).to have_http_status(:found)
      end
    end

    context "somebody else's repository" do
      before do
        login_as(create(:user))
      end

      it "gives a 404" do
        get project_path(repository)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
