module ANSIToHTMLHelper
  # Map ANSI code numbers to CSS styles
  COLOR_MAP = {
    "30" => "black",
    "31" => "red",
    "32" => "green",
    "33" => "yellow",
    "34" => "blue",
    "35" => "magenta",
    "36" => "cyan",
    "37" => "white",
    "90" => "gray",
    "91" => "brightred",
    "92" => "brightgreen",
    "93" => "brightyellow",
    "94" => "brightblue",
    "95" => "brightmagenta",
    "96" => "brightcyan",
    "97" => "brightwhite"
  }

  STYLE_MAP = {
    "1" => "font-weight:bold;",
    "4" => "text-decoration:underline;"
  }

  def ansi_to_html(ansi_string)
    return "" unless ansi_string.present?
    
    # First escape HTML to prevent XSS
    html_string = CGI.escapeHTML(ansi_string.to_s)
    
    # Remove cursor movement and clearing codes
    html_string.gsub!(/(\e|\#033)\[\d+[AB]/, '')  # Cursor up/down
    html_string.gsub!(/(\e|\#033)\[2K/, '')       # Clear line
    html_string.gsub!(/\#015/, '')                # Carriage return
    html_string.gsub!(/\x00|\^@/, '')             # Null characters
    
    # Process complex ANSI codes
    open_spans = []
    
    # Process complex formatting like [1;31m or [1;34;4m
    html_string = html_string.gsub(/(\e|\#033)\[([0-9;]+)m/) do |match|
      codes = $2.split(';')
      
      # If it contains 0, close all open spans and reset
      if codes.include?('0')
        result = open_spans.map { '</span>' }.join
        open_spans = []
        result
      else
        styles = []
        
        # Process color codes
        color_code = codes.find { |c| COLOR_MAP.key?(c) }
        styles << "color:#{COLOR_MAP[color_code]};" if color_code
        
        # Process style codes (bold, underline, etc.)
        style_codes = codes.select { |c| STYLE_MAP.key?(c) }
        styles.concat(style_codes.map { |c| STYLE_MAP[c] })
        
        # Create span with combined styles
        if styles.any?
          span = "<span style=\"#{styles.join(' ')}\">"
          open_spans.push(span)
          span
        else
          ""
        end
      end
    end
    
    # Close any remaining open spans
    html_string += open_spans.map { '</span>' }.join
    
    # Wrap in divs by line
    wrapped_html_string = html_string.split("\n").map do |line|
      "<div>#{line}</div>"
    end.join("")
    
    wrapped_html_string.html_safe
  end
end
