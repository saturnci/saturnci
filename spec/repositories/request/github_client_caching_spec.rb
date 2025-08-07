require "rails_helper"

describe "Repository caching", type: :request do
  # send request with payload including repo_full_name so that a repository is created
  # assert that GitHubClient.repositories includes the new repository

  let!(:user) { create(:user) }
  let!(:github_client) { GitHubClient.new(user) }

  before do
    stub_request(:get, "https://api.github.com/user/repos").
      to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })
  end

  it "works" do
    expect(github_client.repositories.count).to eq(0)
    # send request with payload including repo_full_name so that a repository is created
    post repositories_path, params: { repo_full_name: "foo/bar" }
    expect(github_client.repositories.count).to eq(1)
  end
end
