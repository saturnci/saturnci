module ScrollingHelper
  def scroll_to_bottom(selector)
    page.execute_script <<~JS
      const list = document.querySelector('#{selector}');
      list.scrollTop = list.scrollHeight;
    JS
  end
end
