FactoryBot.define do
  factory :test_case_run do
    run
    identifier { "spec/models/user_spec.rb[1]" }
    path { "spec/models/user_spec.rb" }
    description { "User has a name" }
    line_number { 1 }
    status { "passed" }
    duration { 0.1 }
  end
end
