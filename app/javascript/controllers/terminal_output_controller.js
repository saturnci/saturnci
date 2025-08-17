import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { domRenderDelay: Number }

  connect() {
    this.autoScrollToBottom()
    this.unmaskTerminal()
  }

  autoScrollToBottom() {
    const element = document.querySelector('.run-details')
    
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        element.scrollTop = element.scrollHeight
      })
    })
  }

  unmaskTerminal() {
    const terminal = document.querySelector('.terminal')
    if (terminal) {
      terminal.classList.remove('terminal-masked')
    }
  }
}