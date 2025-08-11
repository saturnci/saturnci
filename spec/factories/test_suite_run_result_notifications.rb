FactoryBot.define do
  factory :test_suite_run_result_notification do
    test_suite_run
    sent_email
    email { "test@example.com" }
  end
end