FactoryBot.define do
  factory :job do
    build
    order_index { 1 }
    runner_id { SecureRandom.hex(6) }

    trait :passed do
      exit_code { 0 }
    end

    trait :failed do
      exit_code { 1 }
    end
  end
end
