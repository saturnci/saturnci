import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.scrollMode = "auto"
    
    // Initial scroll to bottom
    this.autoScrollToBottom()

    document.addEventListener("terminal-output:newContent", () => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          // Skip if element not ready
          if (this.element.scrollHeight === 0) return;
          
          if (this.scrollMode === "auto") {
            this.autoScrollToBottom()
          }
        })
      })
    })

    this.element.addEventListener("scroll", () => {
      this.scrollMode = this.isAtBottom() ? "auto" : "manual"
    })
  }

  isAtBottom() {
    // Defensive check for uninitialized element
    if (this.element.scrollHeight === 0) return true;
    
    return (this.element.scrollTop + this.element.clientHeight) >= this.element.scrollHeight - 5
  }

  autoScrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
