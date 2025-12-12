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
    const additionalItems = list.querySelector("#additional_test_suite_runs");

    // Build new content in a fragment first
    const template = document.createElement("template");
    template.innerHTML = html;
    const newItems = template.content;

    // Skip update if content hasn't changed
    if (this.fingerprint(list) === this.fingerprint(newItems)) {
      return;
    }

    // Preserve active state
    const activeId = list.querySelector("li.active")?.id;
    if (activeId) {
      const activeItem = newItems.querySelector(`#${activeId}`);
      if (activeItem) {
        activeItem.classList.add("active");
      }
    }

    // Atomic swap: remove old, insert new
    list.querySelectorAll(":scope > li").forEach(li => li.remove());
    list.insertBefore(newItems, additionalItems);
  }

  fingerprint(container) {
    return Array.from(container.querySelectorAll("li")).map(li =>
      `${li.id}:${li.textContent.trim()}`
    ).join("|");
  }
}
