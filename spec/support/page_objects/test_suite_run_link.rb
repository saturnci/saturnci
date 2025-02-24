module PageObjects
  class TestSuiteRunLink
    def initialize(page, build)
      @page = page
      @build = build
    end

    def click
      @page.click_on "test_suite_run_link_#{@build.id}"
    end

    def active?
      css_classes.include?("active")
    end

    private

    def css_classes
      @page.find("#test_suite_run_link_#{@build.id}")[:class].split
    end
  end
end
