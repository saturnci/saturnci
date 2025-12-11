FactoryBot.define do
  factory :worker_event do
    association :worker, factory: :worker
    name { "ready_signal_received" }
  end
end
