FactoryBot.define do
  factory :build do
    project
    branch_name { "main" }
    author_name { Faker::Name.name }
    commit_hash { Faker::Alphanumeric.alphanumeric(number: 7) }
    commit_message { "Make change." }

    trait :with_job do
      after(:create) do |build|
        create(:job, build: build)
      end
    end

    trait :with_passed_job do
      after(:create) do |build|
        create(:job, :passed, build: build)
      end
    end

    trait :with_failed_job do
      after(:create) do |build|
        create(:job, :failed, build: build)
      end
    end
  end
end
