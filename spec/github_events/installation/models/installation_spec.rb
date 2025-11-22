require "rails_helper"

describe "installation" do
  let!(:github_user_id) { 12756485 }

  let!(:user) do
    create(:user, uid: github_user_id, provider: "github")
  end

  let!(:payload) do
    {
      "installation" => {
        "id" => 61228390,
        "client_id" => "Iv1.9cbe9d983791f760",
        "account" => {
          "login" => "WholeCellIO",
          "id" => 97552399,
          "node_id" => "O_kgDOBdCIDw",
          "avatar_url" => "https://avatars.githubusercontent.com/u/97552399?v=4",
          "gravatar_id" => "",
          "url" => "https://api.github.com/users/WholeCellIO",
          "html_url" => "https://github.com/WholeCellIO",
          "followers_url" => "https://api.github.com/users/WholeCellIO/followers",
          "following_url" => "https://api.github.com/users/WholeCellIO/following{/other_user}",
          "gists_url" => "https://api.github.com/users/WholeCellIO/gists{/gist_id}",
          "starred_url" => "https://api.github.com/users/WholeCellIO/starred{/owner}{/repo}",
          "subscriptions_url" => "https://api.github.com/users/WholeCellIO/subscriptions",
          "organizations_url" => "https://api.github.com/users/WholeCellIO/orgs",
          "repos_url" => "https://api.github.com/users/WholeCellIO/repos",
          "events_url" => "https://api.github.com/users/WholeCellIO/events{/privacy}",
          "received_events_url" => "https://api.github.com/users/WholeCellIO/received_events",
          "type" => "Organization",
          "user_view_type" => "public",
          "site_admin" => false
        },
        "repository_selection" => "selected",
        "access_tokens_url" => "[FILTERED]",
        "repositories_url" => "https://api.github.com/installation/repositories",
        "html_url" => "https://github.com/organizations/WholeCellIO/settings/installations/61228390",
        "app_id" => 345077,
        "app_slug" => "saturnci",
        "target_id" => 97552399,
        "target_type" => "Organization",
        "permissions" => {
          "organization_projects" => "read",
          "checks" => "write",
          "contents" => "read",
          "metadata" => "read",
          "pull_requests" => "read",
          "repository_hooks" => "read",
          "repository_projects" => "read"
        },
        "events" => ["check_run", "check_suite", "pull_request", "push"],
        "created_at" => "2025-02-17T13:52:00.000-08:00",
        "updated_at" => "2025-02-17T13:52:00.000-08:00",
        "single_file_name" => nil,
        "has_multiple_single_files" => false,
        "single_file_paths" => [],
        "suspended_by" => nil,
        "suspended_at" => nil
      },
      "repositories" => [
        {
          "id" => 111331110,
          "node_id" => "MDEwOlJlcG9zaXRvcnkxMTEzMzExMTA=",
          "name" => "wholecell",
          "full_name" => "WholeCellIO/wholecell",
          "private" => true
        }
      ],
      "requester" => nil,
      "sender" => {
        "login" => "harrysohie",
        "id" => 12756485,
        "node_id" => "MDQ6VXNlcjEyNzU2NDg1",
        "avatar_url" => "https://avatars.githubusercontent.com/u/12756485?v=4",
        "gravatar_id" => "",
        "url" => "https://api.github.com/users/harrysohie",
        "html_url" => "https://github.com/harrysohie",
        "followers_url" => "https://api.github.com/users/harrysohie/followers",
        "following_url" => "https://api.github.com/users/harrysohie/following{/other_user}",
        "gists_url" => "https://api.github.com/users/harrysohie/gists{/gist_id}",
        "starred_url" => "https://api.github.com/users/harrysohie/starred{/owner}{/repo}",
        "subscriptions_url" => "https://api.github.com/users/harrysohie/subscriptions",
        "organizations_url" => "https://api.github.com/users/harrysohie/orgs",
        "repos_url" => "https://api.github.com/users/harrysohie/repos",
        "events_url" => "https://api.github.com/users/harrysohie/events{/privacy}",
        "received_events_url" => "https://api.github.com/users/harrysohie/received_events",
        "type" => "User",
        "user_view_type" => "public",
        "site_admin" => false
      },
      "github_event" => {}
    }
  end

  let!(:push_event) do
    GitHubEvents::Installation.new(payload)
  end

  it "saves the payload" do
    github_account = push_event.process
    expect(github_account.installation_response_payload).to eq(payload)
  end
end
