FactoryBot.define do
  factory :repository do
    github_account
    concurrency { 1 }
    name { "My Repository" }
  end
end
