FactoryBot.define do
  factory :task do
    test_suite_run
    order_index { 1 }
    runner_id { SecureRandom.hex(6) }

    trait :passed do
      exit_code { 0 }

      after(:create) do |task|
        task.test_suite_run.cache_status
      end
    end

    trait :failed do
      exit_code { 1 }

      after(:create) do |task|
        task.test_suite_run.cache_status
      end
    end

    trait :with_worker do
      worker
    end
  end
end
