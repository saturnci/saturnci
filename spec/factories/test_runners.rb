FactoryBot.define do
  factory :test_runner do
    name { Faker::Name.name }
    cloud_id { Faker::Number.number(digits: 10) }
    rsa_key
  end
end
