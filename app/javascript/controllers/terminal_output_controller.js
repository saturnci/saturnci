import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { domRenderDelay: Number }

  connect() {
    this.initializeScrollPolicy()
    this.autoScrollToBottom()
    this.unmaskTerminal()
  }

  initializeScrollPolicy() {
    if (!window.scrollPolicy) {
      window.scrollPolicy = 'auto'
      window.programmaticScroll = false
      
      this.element.addEventListener('scroll', () => {
        if (!window.programmaticScroll) {
          window.scrollPolicy = 'manual'
        }
      })
    }
  }

  autoScrollToBottom() {
    setTimeout(() => {
      if (window.scrollPolicy === 'auto') {
        window.programmaticScroll = true
        this.element.scrollTop = this.element.scrollHeight
        setTimeout(() => {
          window.programmaticScroll = false
        }, 10)
      }
    }, this.domRenderDelayValue)
  }

  unmaskTerminal() {
    const terminal = document.querySelector('.terminal')
    if (terminal) {
      terminal.classList.remove('terminal-masked')
    }
  }
}