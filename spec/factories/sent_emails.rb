FactoryBot.define do
  factory :sent_email do
    to { "test@example.com" }
    subject { "Test Subject" }
    body { "Test Body" }
  end
end