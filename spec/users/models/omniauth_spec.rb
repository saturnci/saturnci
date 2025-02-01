require "rails_helper"

describe "OmniAuth" do
  context "email present" do
    let!(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "github",
        uid: "123456",
        info: OmniAuth::AuthHash::InfoHash.new(
          email: "alex.doe@example.com",
          image: "https://avatars.githubusercontent.com/u/123456?v=4",
          name: "Alex Doe",
          nickname: "alexdoe",
          urls: OmniAuth::AuthHash.new(
            Blog: "http://www.example.com/",
            GitHub: "https://github.com/alexdoe"
          )
        ),
        credentials: OmniAuth::AuthHash.new(
          expires: true,
          expires_at: 1738468817,
          refresh_token: "ghr_************",
          token: "ghu_************"
        ),
        extra: OmniAuth::AuthHash.new(
          all_emails: Hashie::Array.new([]),
          raw_info: {
            avatar_url: "https://avatars.githubusercontent.com/u/123456?v=4",
            bio: "Software engineer and tech enthusiast specializing in web development.",
            blog: "http://www.example.com/",
            company: nil,
            created_at: "2011-03-21T02:44:00Z",
            email: "alex.doe@example.com",
            events_url: "https://api.github.com/users/alexdoe/events{/privacy}",
            followers: 191,
            followers_url: "https://api.github.com/users/alexdoe/followers",
            following: 0,
            following_url: "https://api.github.com/users/alexdoe/following{/other_user}",
            gists_url: "https://api.github.com/users/alexdoe/gists{/gist_id}",
            gravatar_id: "",
            hireable: true,
            html_url: "https://github.com/alexdoe",
            id: 123456,
            location: "Sample City, EX",
            login: "alexdoe",
            name: "Alex Doe",
            node_id: "MDQ6VXNlcjEyMzQ1Ng==",
            notification_email: "alex.doe@example.com",
            organizations_url: "https://api.github.com/users/alexdoe/orgs",
            public_gists: 14,
            public_repos: 123,
            received_events_url: "https://api.github.com/users/alexdoe/received_events",
            repos_url: "https://api.github.com/users/alexdoe/repos",
            site_admin: false,
            starred_url: "https://api.github.com/users/alexdoe/starred{/owner}{/repo}",
            subscriptions_url: "https://api.github.com/users/alexdoe/subscriptions",
            twitter_username: "alexdoe",
            type: "User",
            updated_at: "2024-10-22T21:48:20Z",
            url: "https://api.github.com/users/alexdoe",
            user_view_type: "public"
          },
          scope: ""
        )
      )
    end

    it "works" do
      user = User.from_omniauth(auth_hash)
      expect(user).to be_persisted
    end
  end

  context "email not present" do
    let!(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "github",
        uid: "78901234",
        info: {
          email: nil,
          image: "https://avatars.githubusercontent.com/u/78901234?v=4",
          name: "Evan Brightwood",
          nickname: "evanbrightwood",
          urls: {
            Blog: "https://brightwood.dev",
            GitHub: "https://github.com/evanbrightwood"
          }
        },
        credentials: {
          expires: true,
          expires_at: 1738471224,
          refresh_token: "ghr_************",
          token: "ghu_************"
        },
        extra: {
          all_emails: [],
          raw_info: {
            avatar_url: "https://avatars.githubusercontent.com/u/78901234?v=4",
            bio: nil,
            blog: "https://brightwood.dev",
            company: "@techinnovators",
            created_at: "2016-04-22T15:35:55Z",
            email: nil,
            events_url: "https://api.github.com/users/evanbrightwood/events{/privacy}",
            followers: 4,
            followers_url: "https://api.github.com/users/evanbrightwood/followers",
            following: 2,
            following_url: "https://api.github.com/users/evanbrightwood/following{/other_user}",
            gists_url: "https://api.github.com/users/evanbrightwood/gists{/gist_id}",
            gravatar_id: "",
            hireable: nil,
            html_url: "https://github.com/evanbrightwood",
            id: 78901234,
            location: nil,
            login: "evanbrightwood",
            name: "Evan Brightwood",
            node_id: "MDQ6VXNlcjc4OTAxMjM0",
            notification_email: nil,
            organizations_url: "https://api.github.com/users/evanbrightwood/orgs",
            public_gists: 0,
            public_repos: 1,
            received_events_url: "https://api.github.com/users/evanbrightwood/received_events",
            repos_url: "https://api.github.com/users/evanbrightwood/repos",
            site_admin: false,
            starred_url: "https://api.github.com/users/evanbrightwood/starred{/owner}{/repo}",
            subscriptions_url: "https://api.github.com/users/evanbrightwood/subscriptions",
            twitter_username: nil,
            type: "User",
            updated_at: "2025-02-01T20:38:16Z",
            url: "https://api.github.com/users/evanbrightwood",
            user_view_type: "public"
          },
          scope: ""
        }
      )
    end

    it "works" do
      user = User.from_omniauth(auth_hash)
      expect(user).to be_persisted
    end
  end
end
