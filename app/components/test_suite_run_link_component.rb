class TestSuiteRunLinkComponent < ViewComponent::Base
  attr_reader :build

  def initialize(build, active_build: nil)
    @build = build
    @active_build = active_build
  end

  def css_class
    @build == @active_build ? "active" : ""
  end

  def path
    TestSuiteRunLinkPath.new(@build).value
  end
end
