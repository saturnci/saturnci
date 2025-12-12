FactoryBot.define do
  factory :worker_assignment do
    run
    worker { association :worker, task: run }
  end
end
