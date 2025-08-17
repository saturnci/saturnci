import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { domRenderDelay: Number }

  connect() {
    this.autoScrollToBottom()
    this.unmaskTerminal()
  }

  autoScrollToBottom() {
    const element = document.querySelector('.run-details')
    
    setTimeout(() => {
      element.scrollTop = element.scrollHeight
    }, this.domRenderDelayValue)
  }

  unmaskTerminal() {
    const terminal = document.querySelector('.terminal')
    if (terminal) {
      terminal.classList.remove('terminal-masked')
    }
  }
}