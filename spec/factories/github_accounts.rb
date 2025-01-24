FactoryBot.define do
  factory :github_account do
    user
    github_installation_id { Faker::Number.number(digits: 8).to_s }
  end
end
