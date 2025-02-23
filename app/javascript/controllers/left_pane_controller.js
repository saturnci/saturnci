import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filterForm", "hideFiltersLink"];

  hideFilters(event) {
    this.filterFormTarget.style.display = "none";
    this.hideFiltersLinkTarget.style.display = "none";
    event.preventDefault();
  }
}
