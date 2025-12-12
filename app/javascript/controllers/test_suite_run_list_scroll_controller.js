import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.debouncing = false;
    this.list = this.element.querySelector(".test-suite-run-list");
    this.boundOnScroll = this.onScroll.bind(this);
    this.list.addEventListener("scroll", this.boundOnScroll);
  }

  disconnect() {
    this.list.removeEventListener("scroll", this.boundOnScroll);
  }

  onScroll() {
    const buffer = 800;

    if (this.list.scrollTop + this.list.clientHeight >= this.list.scrollHeight - buffer) {
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
      this.onScroll();
    }, 1000);

    const filterForm = this.element.querySelector(".test-suite-run-filter-form");
    const formData = new FormData(filterForm);
    formData.append("offset", this.itemCount());

    const queryString = new URLSearchParams(formData).toString();
    const url = `${this.element.dataset.url}?${queryString}`;

    const response = await fetch(url, {
      headers: { "Accept": "text/vnd.turbo-stream.html" },
    });

    if (response.ok) {
      Turbo.renderStreamMessage(await response.text());
    }
  }

  itemCount() {
    return this.element.querySelectorAll(".test-suite-run-link").length;
  }
}
