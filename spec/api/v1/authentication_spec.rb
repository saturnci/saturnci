require "rails_helper"

describe "Authentication", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  describe "POST /api/v1/debug_messages" do
    context "with valid Personal Access Token" do
      let!(:personal_access_token) { create(:personal_access_token, user:) }

      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
          user.id.to_s,
          personal_access_token.access_token.value
        )

        post(
          api_v1_debug_messages_path,
          params: { message: "test" },
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end

      context "when user tries to use another user's token" do
        let!(:other_user) { create(:user) }

        it "returns unauthorized" do
          credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
            other_user.id.to_s,
            personal_access_token.access_token.value
          )

          post(
            api_v1_debug_messages_path,
            params: { message: "test" },
            headers: { "Authorization" => credentials }
          )

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "with valid credentials" do
      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id.to_s, user.api_token)

        post(
          api_v1_debug_messages_path,
          params: { message: "test" },
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id.to_s, "wrongtoken")

        post(
          api_v1_debug_messages_path,
          params: { message: "test" },
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "invalid user id" do
      it "returns unauthorized" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials("wrongid", user.api_token)

        post(
          api_v1_debug_messages_path,
          params: { message: "test" },
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with missing credentials" do
      it "returns unauthorized" do
        post(
          api_v1_debug_messages_path,
          params: { message: "test" }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
