module ANSIToHTMLHelper
  RULES = {
    /\e\[0m/ => '</span>', # Reset
    /\e\[1m/ => '<span style="font-weight:bold;">',
    /\e\[32m/ => '<span style="color:green;">',
    /\e\[31m/ => '<span style="color:red;">',
    /\e\[33m/ => '<span style="color:yellow;">',
    /\e\[34m/ => '<span style="color:blue;">',
    /\e\[35m/ => '<span style="color:magenta;">',
    /\e\[36m/ => '<span style="color:cyan;">',
    /\e\[37m/ => '<span style="color:white;">',
    /\e\[\d+A/ => '', # Move cursor up
    /\e\[\d+B/ => '', # Move cursor down
    /\e\[2K/ => '',   # Clear Line
  }

  def ansi_to_html(ansi_string)
    return unless ansi_string.present?

    html_string = CGI.escapeHTML(ansi_string)

    RULES.each do |ansi, html|
      html_string.gsub!(ansi, html)
    end

    html_string.html_safe
  end
end
