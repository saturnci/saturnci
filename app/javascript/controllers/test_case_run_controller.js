import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["link"];

  makeActive(event) {
    console.log("make active");
    this.linkTargets.forEach(link => {
      link.classList.remove("active");
    });

    event.currentTarget.classList.add("active");
  }
}
