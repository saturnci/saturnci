FactoryBot.define do
  factory :worker do
    name { Faker::Name.name }
    cloud_id { Faker::Number.number(digits: 10) }
    rsa_key
    access_token
  end

  factory :test_runner, parent: :worker, class: "TestRunner"
end
