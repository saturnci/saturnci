FactoryBot.define do
  factory :run do
    build
    order_index { 1 }
    job_machine_id { SecureRandom.hex(6) }

    trait :passed do
      exit_code { 0 }
    end

    trait :failed do
      exit_code { 1 }
    end
  end
end
