require "rails_helper"

describe TestSuiteRerun, type: :model do
  let!(:original_test_suite_run) { create(:build) }

  it "does not copy the status" do
    test_suite_run = TestSuiteRerun.create!(original_test_suite_run)
    expect(test_suite_run.status).to eq("Not Started")
  end
end
