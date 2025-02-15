require "rails_helper"

RSpec.describe "API::V1::YourEndpoint", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  describe "GET /api/v1/builds" do
    context "with valid credentials" do
      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id.to_s, user.api_token)

        get(
          api_v1_builds_path,
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id.to_s, "wrongtoken")

        get(
          api_v1_builds_path,
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "invalid user id" do
      it "returns unauthorized" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials("wrongid", user.api_token)

        get(
          api_v1_builds_path,
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with missing credentials" do
      it "returns unauthorized" do
        get api_v1_builds_path

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
