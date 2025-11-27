FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8) }

    trait :with_github_account do
      after(:create) do |user|
        user.github_accounts.create!(
          github_installation_id: "123456"
        )
      end
    end

    trait :with_personal_access_token do
      after(:create) do |user|
        create(:personal_access_token, user:)
      end
    end
  end
end
