class TestSuiteRunNavigation
  def initialize(view_context, run, current_tab_name)
    @view_context = view_context
    @run = run
    @current_tab_name = current_tab_name
  end

  def item(text, current_tab_name)
    @view_context.content_tag(:li) do
      @view_context.link_to(
        text,
        @view_context.task_path(@run, current_tab_name),
        class: @current_tab_name == current_tab_name ? "active" : "",
        data: { turbo_frame: "test_suite_run_body" }
      )
    end
  end
end

module TestSuiteRunNavigationHelper
  def test_suite_run_navigation(run, current_tab_name, &block)
    test_suite_run_navigation = TestSuiteRunNavigation.new(self, run, current_tab_name)
    block.call(test_suite_run_navigation)
  end
end
