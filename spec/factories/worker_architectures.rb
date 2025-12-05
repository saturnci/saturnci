FactoryBot.define do
  factory :worker_architecture do
    sequence(:slug) { |n| "arch-#{n}" }
  end
end
