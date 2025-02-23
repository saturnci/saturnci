import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "filterForm",
    "hideFiltersLink",
    "showFiltersLink",
  ];

  connect() {
    this.showFiltersLinkTarget.style.display = "none";
  }

  hideFilters(event) {
    this.filterFormTarget.style.display = "none";
    this.hideFiltersLinkTarget.style.display = "none";
    this.showFiltersLinkTarget.style.display = "inline";
    event.preventDefault();
  }

  showFilters(event) {
    this.filterFormTarget.style.display = "block";
    this.showFiltersLinkTarget.style.display = "none";
    this.hideFiltersLinkTarget.style.display = "inline";
    event.preventDefault();
  }
}
