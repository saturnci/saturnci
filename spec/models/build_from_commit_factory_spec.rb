require "rails_helper"

describe BuildFromCommitFactory do
  let!(:build) do
    BuildFromCommitFactory.new(commit).build
  end

  it "has a branch name" do
    expect(build.branch_name).to eq("main")
  end

  it "has an author name" do
    expect(build.author_name).to eq("Jason Swett")
  end

  it "has a commit hash" do
    expect(build.commit_hash).to eq("d9e65e719b3fffae853d6264485d3f0467b3d8a3")
  end

  it "has a commit message" do
    expect(build.commit_message).to eq("Change stuff.")
  end

  def commit
    {
      "sha" => "d9e65e719b3fffae853d6264485d3f0467b3d8a3",
      "node_id" => "C_kwDOHLFUTdoAKGQ5ZTY1ZTcxOWIzZmZmYWU4NTNkNjI2NDQ4NWQzZjA0NjdiM2Q4YTM",
      "commit" => {
        "author" => {
          "name" => "Jason Swett",
          "email" => "jason@benfranklinlabs.com",
          "date" => "2025-01-24 20:43:03 UTC"
        },
        "committer" => {
          "name" => "Jason Swett",
          "email" => "jason@benfranklinlabs.com",
          "date" => "2025-01-24 20:43:03 UTC"
        },
        "message" => "Change stuff.",
        "tree" => {
          "sha" => "348ad42a1f99f70357477cb019fb7a5790f5a649",
          "url" => "https://api.github.com/repos/jasonswett/panda/git/trees/348ad42a1f99f70357477cb019fb7a5790f5a649"
        },
        "url" => "https://api.github.com/repos/jasonswett/panda/git/commits/d9e65e719b3fffae853d6264485d3f0467b3d8a3",
        "comment_count" => 0,
        "verification" => {
          "verified" => false,
          "reason" => "unsigned",
          "signature" => nil,
          "payload" => nil,
          "verified_at" => nil
        }
      },
      "url" => "https://api.github.com/repos/jasonswett/panda/commits/d9e65e719b3fffae853d6264485d3f0467b3d8a3",
      "html_url" => "https://github.com/jasonswett/panda/commit/d9e65e719b3fffae853d6264485d3f0467b3d8a3",
      "comments_url" => "https://api.github.com/repos/jasonswett/panda/commits/d9e65e719b3fffae853d6264485d3f0467b3d8a3/comments",
      "author" => {
        "login" => "jasonswett",
        "id" => 680813,
        "node_id" => "MDQ6VXNlcjY4MDgxMw==",
        "avatar_url" => "https://avatars.githubusercontent.com/u/680813?v=4",
        "gravatar_id" => "",
        "url" => "https://api.github.com/users/jasonswett",
        "html_url" => "https://github.com/jasonswett",
        "followers_url" => "https://api.github.com/users/jasonswett/followers",
        "following_url" => "https://api.github.com/users/jasonswett/following{/other_user}",
        "gists_url" => "https://api.github.com/users/jasonswett/gists{/gist_id}",
        "starred_url" => "https://api.github.com/users/jasonswett/starred{/owner}{/repo}",
        "subscriptions_url" => "https://api.github.com/users/jasonswett/subscriptions",
        "organizations_url" => "https://api.github.com/users/jasonswett/orgs",
        "repos_url" => "https://api.github.com/users/jasonswett/repos",
        "events_url" => "https://api.github.com/users/jasonswett/events{/privacy}",
        "received_events_url" => "https://api.github.com/users/jasonswett/received_events",
        "type" => "User",
        "user_view_type" => "public",
        "site_admin" => false
      },
      "committer" => {
        "login" => "jasonswett",
        "id" => 680813,
        "node_id" => "MDQ6VXNlcjY4MDgxMw==",
        "avatar_url" => "https://avatars.githubusercontent.com/u/680813?v=4",
        "gravatar_id" => "",
        "url" => "https://api.github.com/users/jasonswett",
        "html_url" => "https://github.com/jasonswett",
        "followers_url" => "https://api.github.com/users/jasonswett/followers",
        "following_url" => "https://api.github.com/users/jasonswett/following{/other_user}",
        "gists_url" => "https://api.github.com/users/jasonswett/gists{/gist_id}",
        "starred_url" => "https://api.github.com/users/jasonswett/starred{/owner}{/repo}",
        "subscriptions_url" => "https://api.github.com/users/jasonswett/subscriptions",
        "organizations_url" => "https://api.github.com/users/jasonswett/orgs",
        "repos_url" => "https://api.github.com/users/jasonswett/repos",
        "events_url" => "https://api.github.com/users/jasonswett/events{/privacy}",
        "received_events_url" => "https://api.github.com/users/jasonswett/received_events",
        "type" => "User",
        "user_view_type" => "public",
        "site_admin" => false
      },
      "parents" => [
        {
          "sha" => "dc9042639a86de87396beff0edf1f5ff020f4f3c",
          "url" => "https://api.github.com/repos/jasonswett/panda/commits/dc9042639a86de87396beff0edf1f5ff020f4f3c",
          "html_url" => "https://github.com/jasonswett/panda/commit/dc9042639a86de87396beff0edf1f5ff020f4f3c"
        }
      ]
    }
  end
end
