require "rails_helper"

describe TestSuiteRunFinishJob do
  let!(:test_suite_run) { create(:test_suite_run) }

  before do
    allow_any_instance_of(TestSuiteRunFinish).to receive(:process)
  end

  it "calls TestSuiteRunFinish#process" do
    expect_any_instance_of(TestSuiteRunFinish).to receive(:process)
    described_class.new.perform(test_suite_run.id)
  end
end
