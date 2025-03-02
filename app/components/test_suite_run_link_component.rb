class TestSuiteRunLinkComponent < ViewComponent::Base
  attr_reader :build

  def initialize(build, active_build: nil)
    @build = build
    @active_build = active_build
  end

  def path
    TestSuiteRunLinkPath.new(@build).value
  end

  def test_suite_run
    build
  end

  def data
    {
      turbo_frame: "build",
      action: "click->test-suite-run-list#makeActive",
      test_suite_run_list_target: "link"
    }
  end
end
