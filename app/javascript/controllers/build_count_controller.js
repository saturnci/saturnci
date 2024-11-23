import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    buildsUrl: String,
    startingBuildCount: Number
  };

  static targets = ["message"];

  connect() {
    this.pollForBuilds();
  }

  pollForBuilds() {
    setInterval(() => {
      fetch(this.buildsUrlValue)
        .then(response => response.json())
        .then(data => {
          console.log(data.build_count);
          let newBuildCount = data.build_count - this.startingBuildCountValue;
          this.messageTarget.innerText = `${newBuildCount} new build${newBuildCount == 1 ? "" : "s"}`;
        });
    }, 1000)
  }
}
