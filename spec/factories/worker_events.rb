FactoryBot.define do
  factory :worker_event do
    association :worker, factory: :test_runner
    type { 1 }
  end
end
