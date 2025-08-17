import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dispatch("newContent")
    this.unmaskTerminal()
  }

  unmaskTerminal() {
    const terminal = document.querySelector('.terminal')
    if (terminal) {
      terminal.classList.remove('terminal-masked')
    }
  }
}
