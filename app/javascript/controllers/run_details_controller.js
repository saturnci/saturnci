import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { domRenderDelay: Number }

  connect() {
    this.autoScrollToBottom()
    this.unmaskTerminal()
  }

  autoScrollToBottom() {
    setTimeout(() => {
      this.element.scrollTop = this.element.scrollHeight
    }, this.domRenderDelayValue)
  }

  unmaskTerminal() {
    const terminal = document.querySelector('.terminal')
    if (terminal) {
      terminal.classList.remove('terminal-masked')
    }
  }
}