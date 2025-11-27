FactoryBot.define do
  factory :test_runner_assignment do
    association :worker, factory: :test_runner
    run
  end
end
