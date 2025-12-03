FactoryBot.define do
  factory :test_failure_screenshot do
    test_case_run
    path { "screenshots/test_failure.png" }
  end
end
