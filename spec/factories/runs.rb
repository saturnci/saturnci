FactoryBot.define do
  factory :run do
    build
    order_index { 1 }
    runner_id { SecureRandom.hex(6) }

    trait :passed do
      exit_code { 0 }

      after(:create) do |run|
        run.build.cache_status
      end
    end

    trait :failed do
      exit_code { 1 }

      after(:create) do |run|
        run.build.cache_status
      end
    end

    trait :with_worker do
      worker
    end
  end
end
