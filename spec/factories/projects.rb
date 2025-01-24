FactoryBot.define do
  factory :project do
    user
    github_account
    name { "My Project" }
  end
end
