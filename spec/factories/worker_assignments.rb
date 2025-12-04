FactoryBot.define do
  factory :worker_assignment do
    association :worker, factory: :worker
    run
  end
end
