FactoryBot.define do
  factory :test_runner do
    name { Faker::Name.name }
    rsa_key
  end
end
