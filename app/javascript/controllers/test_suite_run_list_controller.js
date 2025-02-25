import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.debouncing = false;
    this.element.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.onScroll.bind(this));
  }

  onScroll() {
    this.checkScrollPosition();
  }

  checkScrollPosition() {
    const list = this.element;
    const buffer = 800;

    if (list.scrollTop + list.clientHeight >= list.scrollHeight - buffer) {
      this.loadMore();
    }
  }

  async loadMore() {
    if (this.debouncing) {
      return;
    }

    this.debouncing = true;

    setTimeout(() => {
      this.debouncing = false;
      this.checkScrollPosition();
    }, 1000);

    const url = `${this.data.get("url")}?offset=${this.testSuiteRunCount()}`;

    const response = await fetch(url, {
      headers: { "Accept": "text/vnd.turbo-stream.html" },
    });

    if (response.ok) {
      const html = await response.text();
      Turbo.renderStreamMessage(html);
    }
  }

  testSuiteRunCount() {
    return this.linkTargets.length;
  }

  makeActive(event) {
    this.linkTargets.forEach(link => {
      link.classList.remove("active");
    });

    event.currentTarget.classList.add("active");
  }
}
