FactoryBot.define do
  factory :rsa_key, class: 'Cloud::RSAKey' do
    public_key_value { "MyText" }
    private_key_value { "MyText" }
  end
end
