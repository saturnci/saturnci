module ApplicationHelper
  def abbreviated_hash(hash)
    hash[0..7]
  end

  def terminal_tag
    content = capture { yield }
    return unless content.present?

    compressed_content = content.gsub(/\n\s+/, "").html_safe
    content_tag(:pre, compressed_content, class: "terminal")
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
    ascii_job_heading(job.order_index) + content_tag(:div, id: dom_id(job, current_tab_name), &block)
  end
end
