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
      this.loadMore();
    }
  }

  loadMore() {
    // hit GET test_case_runs
  }

  makeActive(event) {
    this.linkTargets.forEach(link => {
      link.classList.remove("active");
    });

    event.currentTarget.classList.add("active");
  }
}
