import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "configuratorFrame", "modalTitle"]

  openModal(event) {
    const productSlug = event.currentTarget.dataset.productSlug
    const productName = event.currentTarget.dataset.productName

    // Update modal title
    if (this.hasModalTitleTarget) {
      this.modalTitleTarget.textContent = `Configure ${productName}`
    }

    // Load configurator in turbo frame
    const frameHtml = `<turbo-frame id="addon-configurator-frame" src="/product/${productSlug}?modal=true"></turbo-frame>`
    this.configuratorFrameTarget.innerHTML = frameHtml

    // Open modal
    document.getElementById('addon-modal').showModal()

    // Listen for addon added event to close modal
    this.boundCloseHandler = this.handleAddonAdded.bind(this)
    window.addEventListener('addon:added', this.boundCloseHandler)
  }

  closeModal() {
    document.getElementById('addon-modal').close()

    // Clear frame
    this.configuratorFrameTarget.innerHTML = ''

    // Remove event listener
    if (this.boundCloseHandler) {
      window.removeEventListener('addon:added', this.boundCloseHandler)
    }
  }

  handleAddonAdded(event) {
    // Close modal when addon is added to cart
    this.closeModal()
  }
}
