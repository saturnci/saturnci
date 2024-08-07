FactoryBot.define do
  factory :charge do
    job
    rate { "9.99" }
    job_duration { "9.99" }
  end
end
