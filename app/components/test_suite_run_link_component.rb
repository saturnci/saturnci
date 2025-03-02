class TestSuiteRunLinkComponent < ViewComponent::Base
  attr_reader :build

  def initialize(build, active_build: nil)
    @build = build
    @active_build = active_build
  end

  def css_class
    if @build == @active_build
      "test-suite-run-link active"
    else
      "test-suite-run-link"
    end
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
