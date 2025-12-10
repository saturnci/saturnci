class TestSuiteRunStatusComponent < ViewComponent::Base
  attr_reader :test_suite_run

  def initialize(test_suite_run:)
    @test_suite_run = test_suite_run
  end
end
