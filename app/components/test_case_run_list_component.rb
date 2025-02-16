class TestCaseRunListComponent < ViewComponent::Base
  attr_reader :build, :active_test_case_run

  def initialize(build:, active_test_case_run:)
    @build = build
    @active_test_case_run = active_test_case_run
  end
end
