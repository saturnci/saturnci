module ApplicationHelper
  def abbreviated_hash(hash)
    hash[0..7]
  end

  def terminal_output(extra_css_classes = "")
    content = capture { yield }
    return unless content.present?

    compressed_content = content.gsub(/\n\s+/, "").html_safe
    terminal_content = content_tag(:pre, compressed_content, class: "terminal #{extra_css_classes}")
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
