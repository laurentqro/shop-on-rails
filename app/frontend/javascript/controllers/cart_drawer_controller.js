import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    if (event.detail.success) {
      const drawer = document.querySelector('#cart-drawer')
      drawer.checked = true
    }
  }

  close(event) {
    if (event.detail.success) {
      const drawer = document.querySelector('#cart-drawer')
      drawer.checked = false
    }
  }
} 