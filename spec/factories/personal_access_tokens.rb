FactoryBot.define do
  factory :personal_access_token do
    user
    access_token
  end
end
