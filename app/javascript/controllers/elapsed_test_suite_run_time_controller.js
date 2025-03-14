import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value"];
  static values = { testSuiteRunStartedAtDatetime: String };

  connect() {
    if (!this.hasValueTarget) {
      return;
    }

    this.startTime = new Date(this.testSuiteRunStartedAtDatetimeValue);

    setInterval(() => {
      this.valueTarget.textContent = this.elapsedTime();
    }, 1000);
  }

  elapsedTime() {
    const now = new Date();
    const elapsed = Math.floor((now - this.startTime) / 1000);

    if (isNaN(elapsed)) {
      return "";
    }

    const minutes = String(Math.floor((elapsed % 3600) / 60)).padStart(2, '0');
    const seconds = String(elapsed % 60).padStart(2, '0');
    return `${minutes}:${seconds}`;
  }
}
