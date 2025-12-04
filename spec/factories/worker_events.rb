FactoryBot.define do
  factory :worker_event do
    association :worker, factory: :worker
    type { 1 }
  end
end
