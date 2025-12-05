FactoryBot.define do
  factory :project do
    github_account
    worker_architecture
    concurrency { 1 }
    name { "My Project" }
  end
end
