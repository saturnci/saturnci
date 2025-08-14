module PageObjects
  class LogConsole
    def initialize(page)
      @page = page
    end

    def has_visible_text?(text)
      escaped_text = text.gsub("'", "\\\\'").gsub('"', '\\"')
      @page.evaluate_script(<<-JS)
        (function() {
          var element = document.evaluate(
            "//*[contains(text(), '#{escaped_text}')]",
            document,
            null,
            XPathResult.FIRST_ORDERED_NODE_TYPE,
            null
          ).singleNodeValue;

          if (!element) {
            return false;
          } else {
            var rect = element.getBoundingClientRect();
            return rect.top < window.innerHeight && rect.bottom >= 0;
          }
        })();
      JS
    end
  end
end