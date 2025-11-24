module PageObjects
  class TestSuiteRunLink
    def initialize(page, test_suite_run)
      @page = page
      @test_suite_run = test_suite_run
    end

    def click
      @page.click_on "test_suite_run_link_#{@test_suite_run.id}"
    end

    def active?
      css_classes.include?("active")
    end

    private

    def css_classes
      link = @page.find("#test_suite_run_link_#{@test_suite_run.id}")
      link.ancestor("li")[:class].split
    end
  end
end
