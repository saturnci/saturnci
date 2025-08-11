require "rails_helper"

RSpec.describe "TestSuiteRun.needing_notification" do
  let!(:test_suite_run) { create(:test_suite_run) }
  
  context "when test suite run does not have a notification" do
    it "includes the test suite run" do
      expect(TestSuiteRun.needing_notification).to include(test_suite_run)
    end
  end
  
  context "when test suite run already has a notification" do
    before do
      create(:test_suite_run_result_notification, test_suite_run:)
    end
    
    it "does not include the test suite run" do
      expect(TestSuiteRun.needing_notification).not_to include(test_suite_run)
    end
  end
end
