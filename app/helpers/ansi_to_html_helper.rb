module ANSIToHTMLHelper
  RULES = {
    # Reset styles
    /\e\[0m/ => '</span>',
    /#033\[0m/ => '</span>',

    # Bold
    /\e\[1m/ => '<span style="font-weight:bold;">',
    /#033\[1m/ => '<span style="font-weight:bold;">',

    # Colors
    /\e\[32m/ => '<span style="color:green;">',
    /#033\[32m/ => '<span style="color:green;">',

    /\e\[31m/ => '<span style="color:red;">',
    /#033\[31m/ => '<span style="color:red;">',

    /\e\[33m/ => '<span style="color:yellow;">',
    /#033\[33m/ => '<span style="color:yellow;">',

    /\e\[34m/ => '<span style="color:blue;">',
    /#033\[34m/ => '<span style="color:blue;">',

    /\e\[35m/ => '<span style="color:magenta;">',
    /#033\[35m/ => '<span style="color:magenta;">',

    /\e\[36m/ => '<span style="color:cyan;">',
    /#033\[36m/ => '<span style="color:cyan;">',

    /\e\[37m/ => '<span style="color:white;">',
    /#033\[37m/ => '<span style="color:white;">',

    # Cursor movements
    /\e\[\d+A/ => '', # Move cursor up
    /#033\[\d+A/ => '',

    /\e\[\d+B/ => '', # Move cursor down
    /#033\[\d+B/ => '',

    # Clear line
    /\e\[2K/ => '',
    /#033\[2K/ => '',

    # Carriage return
    /#015/ => '',

    # Null characters
    /\x00/ => '',
    /\^@/ => ''
  }

  def ansi_to_html(ansi_string)
    return unless ansi_string.present?

    html_string = CGI.escapeHTML(ansi_string)

    RULES.each do |ansi, html|
      html_string.gsub!(ansi, html)
    end

    wrapped_html_string = html_string.split("\n").map do |line|
      "<div>#{line}</div>"
    end.join("")

    wrapped_html_string.html_safe
  end
end
