import { Controller } from "@hotwired/stimulus"

// Handles hover effect on product cards to show lifestyle photo
// Fades from product_photo to lifestyle_photo on mouse enter
// Only activates when both photos are present
export default class extends Controller {
  static targets = ["productPhoto", "lifestylePhoto"]

  connect() {
    // Only enable hover if both photos exist
    if (!this.hasLifestylePhotoTarget) {
      return
    }

    // Set initial state: lifestyle photo hidden
    this.lifestylePhotoTarget.style.opacity = "0"
  }

  mouseenter() {
    if (!this.hasLifestylePhotoTarget) return

    // Fade out product photo, fade in lifestyle photo
    this.productPhotoTarget.style.opacity = "0"
    this.lifestylePhotoTarget.style.opacity = "1"
  }

  mouseleave() {
    if (!this.hasLifestylePhotoTarget) return

    // Fade in product photo, fade out lifestyle photo
    this.productPhotoTarget.style.opacity = "1"
    this.lifestylePhotoTarget.style.opacity = "0"
  }
}
