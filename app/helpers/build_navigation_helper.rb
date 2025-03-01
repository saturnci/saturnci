class BuildNavigation
  def initialize(view_context, run, current_tab_name)
    @view_context = view_context
    @run = run
    @current_tab_name = current_tab_name
  end

  def item(text, current_tab_name)
    @view_context.content_tag(:li) do
      @view_context.link_to(
        text,
        @view_context.run_path(@run, current_tab_name),
        class: @current_tab_name == current_tab_name ? "active" : "",
        data: { turbo_frame: "test_suite_run_body" }
      )
    end
  end
end

module BuildNavigationHelper
  def build_navigation(run, current_tab_name, &block)
    build_navigation = BuildNavigation.new(self, run, current_tab_name)
    block.call(build_navigation)
  end
end
