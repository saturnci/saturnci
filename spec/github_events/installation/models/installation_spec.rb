require "rails_helper"

describe "installation" do
  let!(:github_account_id) { "680813" }

  let!(:user) do
    create(:user, uid: github_account_id, provider: "github")
  end

  let!(:payload) do
    {"action"=>"created",
     "installation"=>
    {"id"=>60091743,
     "client_id"=>"Iv1.0033cee7a1fb452e",
     "account"=>
    {"login"=>"saturnci",
     "id"=>185959384,
     "node_id"=>"O_kgDOCxWD2A",
     "avatar_url"=>"https://avatars.githubusercontent.com/u/185959384?v=4",
     "gravatar_id"=>"",
     "url"=>"https://api.github.com/users/saturnci",
     "html_url"=>"https://github.com/saturnci",
     "followers_url"=>"https://api.github.com/users/saturnci/followers",
     "following_url"=>"https://api.github.com/users/saturnci/following{/other_user}",
     "gists_url"=>"https://api.github.com/users/saturnci/gists{/gist_id}",
     "starred_url"=>"https://api.github.com/users/saturnci/starred{/owner}{/repo}",
     "subscriptions_url"=>"https://api.github.com/users/saturnci/subscriptions",
     "organizations_url"=>"https://api.github.com/users/saturnci/orgs",
     "repos_url"=>"https://api.github.com/users/saturnci/repos",
     "events_url"=>"https://api.github.com/users/saturnci/events{/privacy}",
     "received_events_url"=>"https://api.github.com/users/saturnci/received_events",
     "type"=>"Organization",
     "user_view_type"=>"public",
     "site_admin"=>false},
     "repository_selection"=>"selected",
     "access_tokens_url"=>"https://api.github.com/app/installations/60091743/access_tokens",
     "repositories_url"=>"https://api.github.com/installation/repositories",
     "html_url"=>"https://github.com/organizations/saturnci/settings/installations/60091743",
     "app_id"=>350839,
     "app_slug"=>"saturnci-development",
     "target_id"=>185959384,
     "target_type"=>"Organization",
     "permissions"=>
    {"organization_projects"=>"read",
     "contents"=>"read",
     "metadata"=>"read",
     "pull_requests"=>"read",
     "repository_hooks"=>"read",
     "repository_projects"=>"read"},
     "events"=>["pull_request", "push"],
     "created_at"=>"2025-01-26T09:46:00.000-05:00",
     "updated_at"=>"2025-01-26T09:46:01.000-05:00",
     "single_file_name"=>nil,
     "has_multiple_single_files"=>false,
     "single_file_paths"=>[],
     "suspended_by"=>nil,
     "suspended_at"=>nil},
     "repositories"=>
    [{"id"=>648845192, "node_id"=>"R_kgDOJqyXiA", "name"=>"saturnci", "full_name"=>"saturnci/saturnci", "private"=>false}],
      "requester"=>nil,
      "sender"=>
    {"login"=>"jasonswett",
     "id"=>680813,
     "node_id"=>"MDQ6VXNlcjY4MDgxMw==",
     "avatar_url"=>"https://avatars.githubusercontent.com/u/680813?v=4",
     "gravatar_id"=>"",
     "url"=>"https://api.github.com/users/jasonswett",
     "html_url"=>"https://github.com/jasonswett",
     "followers_url"=>"https://api.github.com/users/jasonswett/followers",
     "following_url"=>"https://api.github.com/users/jasonswett/following{/other_user}",
     "gists_url"=>"https://api.github.com/users/jasonswett/gists{/gist_id}",
     "starred_url"=>"https://api.github.com/users/jasonswett/starred{/owner}{/repo}",
     "subscriptions_url"=>"https://api.github.com/users/jasonswett/subscriptions",
     "organizations_url"=>"https://api.github.com/users/jasonswett/orgs",
     "repos_url"=>"https://api.github.com/users/jasonswett/repos",
     "events_url"=>"https://api.github.com/users/jasonswett/events{/privacy}",
     "received_events_url"=>"https://api.github.com/users/jasonswett/received_events",
     "type"=>"User",
     "user_view_type"=>"public",
     "site_admin"=>false}}
  end

  let!(:push_event) do
    GitHubEvents::Installation.new(payload)
  end

  it "saves the payload" do
    github_account = push_event.process
    expect(github_account.installation_response_payload).to eq(payload)
  end
end
