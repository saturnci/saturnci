class BuildNavigation
  def initialize(view_context, run, partial)
    @view_context = view_context
    @run = run
    @partial = partial
  end

  def item(text, slug)
    @view_context.content_tag(:li) do
      @view_context.link_to(
        text,
        @view_context.run_path(@run, slug),
        class: @partial == slug ? "active" : "",
        data: { turbo_frame: "build_details" }
      )
    end
  end
end

module BuildNavigationHelper
  def build_navigation(run, partial, &block)
    build_navigation = BuildNavigation.new(self, run, partial)
    block.call(build_navigation)
  end
end
