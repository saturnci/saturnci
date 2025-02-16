import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.element.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.onScroll.bind(this));
  }

  onScroll() {
    const list = this.element;
    const buffer = 10;

    if (list.scrollTop + list.clientHeight >= list.scrollHeight - buffer) {
      console.log("load more");
      this.loadMore();
    }
  }

  async loadMore() {
    const buildId = this.data.get("buildId");
    const url = `/builds/${buildId}/test_case_runs`;

    const response = await fetch(url, {
      headers: { "Accept": "text/vnd.turbo-stream.html" },
    });

    if (response.ok) {
      const html = await response.text();
      Turbo.renderStreamMessage(html);
    }
  }

  makeActive(event) {
    this.linkTargets.forEach(link => {
      link.classList.remove("active");
    });

    event.currentTarget.classList.add("active");
  }
}
