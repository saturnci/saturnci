import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.pollInterval = setInterval(() => this.poll(), 1000);
  }

  disconnect() {
    clearInterval(this.pollInterval);
  }

  async poll() {
    const filterForm = this.element.querySelector(".test-suite-run-filter-form");
    const formData = new FormData(filterForm);
    const queryString = new URLSearchParams(formData).toString();
    const url = `${this.element.dataset.url}?${queryString}`;

    const response = await fetch(url, {
      headers: { "Accept": "text/html" }
    });

    if (response.ok) {
      this.updateList(await response.text());
    }
  }

  updateList(html) {
    const list = this.element.querySelector("#test-suite-run-list");
    const activeId = list.querySelector("li.active")?.id;

    const additionalItems = list.querySelector("#additional_test_suite_runs");
    list.querySelectorAll(":scope > li").forEach(li => li.remove());
    additionalItems.insertAdjacentHTML("beforebegin", html);

    if (activeId) {
      list.querySelector(`#${activeId}`)?.classList.add("active");
    }
  }
}
