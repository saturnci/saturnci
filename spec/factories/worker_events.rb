FactoryBot.define do
  factory :test_runner_event do
    association :worker, factory: :test_runner
    type { 1 }
  end
end
