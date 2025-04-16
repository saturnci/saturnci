FactoryBot.define do
  factory :repository do
    user
    github_account
    concurrency { 1 }
    name { "My Repository" }
  end
end
