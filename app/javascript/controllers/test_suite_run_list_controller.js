import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  makeActive(event) {
    this.linkTargets.forEach(link => {
      link.closest("li").classList.remove("active");
    });

    event.currentTarget.closest("li").classList.add("active");
  }
}
