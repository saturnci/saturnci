require "rails_helper"

describe TestSuiteRunFilterComponent do
  let!(:test_suite_run_filter_component) do
    TestSuiteRunFilterComponent.new(
      test_suite_run: nil,
      branch_name: nil,
      checked_statuses: ["Passed"],
      current_tab_name: nil
    )
  end

  context "status is checked" do
    it "returns true" do
      expect(test_suite_run_filter_component.checked?("Passed")).to be true
    end
  end

  context "status is not checked" do
    it "returns false" do
      expect(test_suite_run_filter_component.checked?("Failed")).to be false
    end
  end
end
