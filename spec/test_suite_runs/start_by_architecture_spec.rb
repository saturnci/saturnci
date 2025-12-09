require "rails_helper"

describe "TestSuiteRun#start!" do
  let!(:test_suite_run) { create(:test_suite_run) }

  it "calls Nova.start_test_suite_run" do
    expect(Nova).to receive(:start_test_suite_run).with(test_suite_run, anything)
    test_suite_run.start!
  end
end
