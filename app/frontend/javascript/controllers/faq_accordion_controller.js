import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "content", "icon"]

  connect() {
    // Open first category by default
    if (this.element === this.element.parentElement.firstElementChild) {
      this.open()
    }
  }

  toggle(event) {
    const content = event.currentTarget.nextElementSibling
    const icon = event.currentTarget.querySelector('[data-faq-accordion-target="icon"]')

    if (content.classList.contains('hidden')) {
      content.classList.remove('hidden')
      icon.style.transform = 'rotate(180deg)'
    } else {
      content.classList.add('hidden')
      icon.style.transform = 'rotate(0deg)'
    }
  }

  open() {
    const content = this.contentTarget
    const icon = this.iconTarget

    content.classList.remove('hidden')
    icon.style.transform = 'rotate(180deg)'
  }
}
