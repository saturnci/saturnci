module ApplicationHelper
  DEFAULT_PARTIAL = "test_output"

  def build_home_path(build)
    if build.runs.any?
      failed_runs = build.runs.select(&:failed?)
      failed_runs.first || build.runs.first

      run_path(
        failed_runs.first || build.runs.first,
        DEFAULT_PARTIAL,
        branch_name: params[:branch_name],
        statuses: params[:statuses]
      )
    else
      project_build_path(build.project, build)
    end
  end

  def abbreviated_hash(hash)
    hash[0..7]
  end

  def terminal_output
    content = capture { yield }
    return unless content.present?

    compressed_content = content.gsub(/\n\s+/, "").html_safe
    terminal_content = content_tag(:pre, compressed_content, class: "terminal")
    content_tag(:div, terminal_content, class: "run-info-container")
  end

  def run_container(current_tab_name, run, &block)
    run_info = capture { yield }
    if run_info.present?
      content_tag(:div, id: dom_id(run, current_tab_name), &block)
    else
      content_tag(:div, Quote.random) +
        content_tag(:br) +
        content_tag(:div, "Waiting for test suite to start...")
    end
  end
end
