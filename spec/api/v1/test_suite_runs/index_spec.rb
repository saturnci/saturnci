require "rails_helper"

describe "GET /api/v1/test_suite_runs", type: :request do
  let!(:user) { create(:user, :with_personal_access_token) }

  let!(:accessible_repository) { create(:repository) }
  let!(:accessible_test_suite_run) { create(:test_suite_run, repository: accessible_repository) }

  let!(:inaccessible_repository) { create(:repository) }
  let!(:inaccessible_test_suite_run) { create(:test_suite_run, repository: inaccessible_repository) }

  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(
      user.id.to_s,
      user.personal_access_tokens.first.access_token.value
    )
  end

  before do
    allow_any_instance_of(User).to receive(:github_repositories).and_return([accessible_repository])
  end

  it "includes test suite runs from repositories the user can access" do
    get(api_v1_test_suite_runs_path, headers: { "Authorization" => credentials })

    ids = JSON.parse(response.body).map { |test_suite_run| test_suite_run["id"] }
    expect(ids).to include(accessible_test_suite_run.id)
  end

  it "excludes test suite runs from repositories the user cannot access" do
    get(api_v1_test_suite_runs_path, headers: { "Authorization" => credentials })

    ids = JSON.parse(response.body).map { |test_suite_run| test_suite_run["id"] }
    expect(ids).not_to include(inaccessible_test_suite_run.id)
  end
end
