FactoryBot.define do
  factory :failure_rerun do
    original_test_suite_run { association :test_suite_run }
    test_suite_run { association :test_suite_run }
  end
end
