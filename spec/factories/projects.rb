FactoryBot.define do
  factory :project do
    github_account
    concurrency { 1 }
    name { "My Project" }
  end
end
