require "rails_helper"

describe User, type: :model do
  it "has an api_token" do
    user = create(:user)
    expect(user.api_token).to be_present
  end

  describe "#github_repositories" do
    it "returns repositories from GitHub API" do
      user = create(:user)

      # Create a matching repository in the database
      repository = create(:repository, github_repo_full_name: "user/repo1")

      stub_request(:get, "https://api.github.com/user/repos")
        .to_return(
          status: 200, 
          body: [{ full_name: "user/repo1", name: "repo1" }].to_json,
          headers: { 
            "Content-Type" => "application/json",
            "Link" => "" # No pagination
          }
        )

      result = user.github_repositories
      expect(result).to eq([repository])
    end
  end
end
