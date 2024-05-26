module ApplicationHelper
  def abbreviated_hash(hash)
    hash[0..7]
  end

  def terminal_output
    content = capture { yield }
    return unless content.present?

    compressed_content = content.gsub(/\n\s+/, "").html_safe
    terminal_content = content_tag(:pre, compressed_content, class: "terminal")
    content_tag(:div, terminal_content, class: "job-info-container")
  end

  def job_container(current_tab_name, job, &block)
    job_info = capture { yield }
    if job_info.present?
      content_tag(:div, id: dom_id(job, current_tab_name), &block)
    else
      content_tag(:div, "Nothing here yet")
    end
  end
end
