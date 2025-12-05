FactoryBot.define do
  factory :worker_architecture do
    initialize_with { WorkerArchitecture.terra }
  end
end
