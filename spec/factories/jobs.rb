FactoryBot.define do
  factory :job do
    build
    order_index { 1 }
    job_machine_id { SecureRandom.hex(6) }

    trait :passed do
      test_output { "Script done on 2024-10-20 13:41:25+00:00 [COMMAND_EXIT_CODE=\"0\"]" }
    end

    trait :failed do
      test_output { "Script done on 2024-10-20 13:41:25+00:00 [COMMAND_EXIT_CODE=\"1\"]" }
    end
  end
end
