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
end
