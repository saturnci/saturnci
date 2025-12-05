require "rails_helper"

describe "Repository caching", type: :request do
  let!(:user) { create(:user) }
  let!(:github_account) { create(:github_account, user:) }
  let!(:github_client) { GitHubClient.new(user) }

  before do
    login_as(user)

    stub_request(:get, "https://api.github.com/user/repos").
      to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })
  end

  context "repository gets added" do
    it "can be retrieved" do
      allow(github_client).to receive(:octokit_repositories).and_return([])
      expect(github_client.repositories.count).to eq(0)

      octokit_repository = double("Octokit::Repository")
      allow(octokit_repository).to receive(:full_name).and_return("foo/bar")
      allow(github_client).to receive(:octokit_repositories).and_return([octokit_repository])

      post repositories_path, params: { repo_full_name: "foo/bar" }

      expect(github_client.repositories.count).to eq(1)
    end
  end
end
