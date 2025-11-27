FactoryBot.define do
  factory :test_runner_event do
    test_runner { nil }
    type { 1 }
  end
end
