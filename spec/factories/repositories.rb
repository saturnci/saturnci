FactoryBot.define do
  factory :repository do
    github_account
    worker_architecture
    concurrency { 1 }
    name { "My Repository" }
  end
end
