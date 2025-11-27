require "rails_helper"

describe "POST /api/v1/test_suite_runs", type: :request do
  let!(:user) { create(:user, :with_personal_access_token, super_admin: true) }
  let!(:repository) { create(:repository, github_repo_full_name: "jasonswett/panda") }

  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(
      user.id.to_s,
      user.personal_access_tokens.first.access_token.value
    )
  end

  let(:params) do
    {
      repository: "jasonswett/panda",
      commit_hash: "abc123",
      branch_name: "main",
      commit_message: "Test commit",
      author_name: "Test Author"
    }
  end

  describe "with valid params" do
    it "creates a test suite run" do
      expect {
        post(
          api_v1_test_suite_runs_path,
          params:,
          headers: { "Authorization" => credentials }
        )
      }.to change(TestSuiteRun, :count).by(1)
    end

    it "returns the test suite run id" do
      post(
        api_v1_test_suite_runs_path,
        params:,
        headers: { "Authorization" => credentials }
      )

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["id"]).to eq(TestSuiteRun.last.id)
    end

    it "creates runs" do
      repository.update!(concurrency: 2)

      post(
        api_v1_test_suite_runs_path,
        params:,
        headers: { "Authorization" => credentials }
      )

      expect(TestSuiteRun.last.runs.count).to eq(2)
    end

    it "returns the run ids" do
      repository.update!(concurrency: 2)

      post(
        api_v1_test_suite_runs_path,
        params:,
        headers: { "Authorization" => credentials }
      )

      response_body = JSON.parse(response.body)
      expect(response_body["runs"].count).to eq(2)
    end
  end
end
