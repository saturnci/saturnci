class TestSuiteRunLinkComponent < ViewComponent::Base
  attr_reader :test_suite_run

  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def self.refresh(test_suite_run)
    Turbo::StreamsChannel.broadcast_replace_to(
      "test_suite_run_link_#{test_suite_run.id}",
      target: "test_suite_run_link_#{test_suite_run.id}",
      html: ApplicationController.render(
        TestSuiteRunLinkComponent.new(test_suite_run),
        layout: false
      )
    )
  end

  def path
    TestSuiteRunLinkPath.new(@test_suite_run).value
  end

  def data
    {
      turbo_frame: "test_suite_run",
      action: "click->test-suite-run-list#makeActive",
      test_suite_run_list_target: "link"
    }
  end
end
