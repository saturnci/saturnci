FactoryBot.define do
  factory :test_suite_run do
    repository
    branch_name { "main" }
    author_name { Faker::Name.name }
    commit_hash { Faker::Alphanumeric.alphanumeric(number: 7) }
    commit_message { "Make change." }

    trait :with_run do
      after(:create) do |test_suite_run|
        create(:run, test_suite_run: test_suite_run)
      end
    end

    trait :with_passed_run do
      after(:create) do |test_suite_run|
        create(:run, :passed, test_suite_run: test_suite_run)
      end
    end

    trait :with_failed_run do
      after(:create) do |test_suite_run|
        create(:run, :failed, test_suite_run: test_suite_run)
      end
    end
  end
end
