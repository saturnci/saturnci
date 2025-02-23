import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filterForm"];

  hideFilters() {
    this.filterFormTarget.style.display = "none";
  }
}
