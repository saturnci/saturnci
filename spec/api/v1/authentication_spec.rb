require "rails_helper"

describe "Authentication", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  describe "GET /api/v1/test_suite_runs" do
    context "with valid Personal Access Token" do
      let!(:personal_access_token) { create(:personal_access_token, user:) }

      before do
        allow_any_instance_of(User).to receive(:github_repositories).and_return([])
      end

      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
          user.id.to_s,
          personal_access_token.access_token.value
        )

        get(
          api_v1_test_suite_runs_path,
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

          get(
            api_v1_test_suite_runs_path,
            headers: { "Authorization" => credentials }
          )

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(user.id.to_s, "wrongtoken")

        get(
          api_v1_test_suite_runs_path,
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with missing credentials" do
      it "returns unauthorized" do
        get(api_v1_test_suite_runs_path)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
