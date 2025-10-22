import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Cart drawer controller connected')
  }

  open(event) {
    if (event.detail.success) {
      console.log('Opening cart drawer')
      const drawer = document.querySelector('#cart-drawer')
      if (drawer) {
        console.log('Drawer found, setting checked to true')
        drawer.checked = true
      }
    }
  }

  close(event) {
    if (event.detail.success) {
      console.log('Closing cart drawer')
      const drawer = document.querySelector('#cart-drawer')
      if (drawer) {
        console.log('Drawer found, setting checked to false')
        drawer.checked = false
      }
    }
  }
} 