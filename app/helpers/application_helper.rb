module ApplicationHelper
  def abbreviated_hash(hash)
    hash[0..7]
  end

  def terminal_output
    content = capture { yield }
    return unless content.present?

    compressed_content = content.gsub(/\n\s+/, "").html_safe
    terminal_content = content_tag(:pre, compressed_content, class: "terminal")
    content_tag(:div, terminal_content, class: "terminal-container")
  end

  def ascii_job_heading(job_order_index)
    line = "-" * 40
    content_tag(:div) do
      concat("#{line}<br>".html_safe)
      concat("Job #{job_order_index}<br>".html_safe)
      concat("#{line}<br><br>".html_safe)
    end
  end

  def job_container(current_tab_name, job, &block)
    content = ascii_job_heading(job.order_index)

    job_info = capture { yield }
    if job_info.present?
      content + content_tag(:div, id: dom_id(job, current_tab_name), &block)
    else
      content + content_tag(:div, "Nothing here yet")
    end
  end
end
