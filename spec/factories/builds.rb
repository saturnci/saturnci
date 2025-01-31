FactoryBot.define do
  factory :build do
    project
    branch_name { "main" }
    author_name { Faker::Name.name }
    commit_hash { Faker::Alphanumeric.alphanumeric(number: 7) }
    commit_message { "Make change." }

    trait :with_run do
      after(:create) do |build|
        create(:run, build: build)
      end
    end

    trait :with_passed_run do
      after(:create) do |build|
        create(:run, :passed, build: build)
      end
    end

    trait :with_failed_run do
      after(:create) do |build|
        create(:run, :failed, build: build)
      end
    end
  end
end
