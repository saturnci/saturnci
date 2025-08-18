import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.scrollMode = "auto"
    this.autoScrollToBottom()

    document.addEventListener("terminal-output:newContent", () => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
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
    return (this.element.scrollTop + this.element.clientHeight) >= this.element.scrollHeight - 5
  }

  autoScrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
