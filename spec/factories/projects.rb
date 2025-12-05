FactoryBot.define do
  factory :project do
    github_account
    worker_architecture { WorkerArchitecture.find_or_create_by(slug: "terra") }
    concurrency { 1 }
    name { "My Project" }
  end
end
