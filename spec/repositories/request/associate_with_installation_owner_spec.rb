require "rails_helper"

describe "adding a repository", type: :request do
  context "when user has multiple GitHub installations" do
    let!(:user) { create(:user) }

    let!(:personal_installation) do
      create(:github_account,
        user: user,
        github_installation_id: "111",
        account_name: "jasonswett"
      )
    end

    let!(:acme_corp_installation) do
      create(:github_account,
        user: user,
        github_installation_id: "222",
        account_name: "acme-corp"
      )
    end

    before do
      login_as(user)

      stub_request(:get, "https://api.github.com/user/repos")
        .to_return(status: 200, body: "[]", headers: { "Content-Type" => "application/json" })

      user_client = instance_double(Octokit::Client)
      allow(user_client).to receive(:user).and_return({ login: "jasonswett" })
      allow(user).to receive(:octokit_client).and_return(user_client)

      github_client = instance_double(GitHubClient)
      allow(GitHubClient).to receive(:new).with(user).and_return(github_client)
      allow(github_client).to receive(:invalidate_repositories_cache)
    end

    it "queries GitHub API to determine which installation owns the repository" do
      jwt_client = instance_double(Octokit::Client)
      allow(Octokit::Client).to receive(:new).and_return(jwt_client)
      allow(jwt_client).to receive(:find_repository_installation)
        .with("acme-corp/api")
        .and_return({ id: "222" })

      post repositories_path, params: { repo_full_name: "acme-corp/api" }

      repository = Repository.find_by(github_repo_full_name: "acme-corp/api")
      expect(repository.github_account).to eq(acme_corp_installation)
    end
  end
end
