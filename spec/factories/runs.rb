FactoryBot.define do
  factory :run do
    build
    order_index { 1 }
    runner_id { SecureRandom.hex(6) }

    trait :passed do
      exit_code { 0 }
    end

    trait :failed do
      exit_code { 1 }
    end

    trait :with_worker do
      worker
    end
  end
end
