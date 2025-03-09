FactoryBot.define do
  factory :rsa_key do
    run { nil }
    public_key_value { "MyText" }
    private_key_value { "MyText" }
  end
end
