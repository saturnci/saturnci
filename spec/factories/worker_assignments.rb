FactoryBot.define do
  factory :worker_assignment, aliases: [:test_runner_assignment] do
    association :worker, factory: :worker
    run
  end
end
