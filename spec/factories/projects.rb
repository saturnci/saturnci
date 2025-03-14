FactoryBot.define do
  factory :project do
    user
    github_account
    concurrency { 1 }
    name { "My Project" }
  end
end
