import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  connect() {
    this.moreHaveBeenLoaded = false;
    this.element.addEventListener("scroll", this.onScroll.bind(this));
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.onScroll.bind(this));
  }

  onScroll() {
    const list = this.element;
    const buffer = 800;

    if (list.scrollTop + list.clientHeight >= list.scrollHeight - buffer) {
      this.loadMore();
    }
  }

  async loadMore() {
    if (this.moreHaveBeenLoaded) {
      return;
    }

    this.moreHaveBeenLoaded = true;

    const response = await fetch(this.data.get("url"), {
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
