import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Handle deep links on page load
    if (window.location.hash) {
      this.openLinkedQuestion()
    }
  }

  openLinkedQuestion() {
    const hash = window.location.hash.substring(1) // Remove #
    const categoryId = hash.split('-')[0] // Get category part before question ID

    // Find the accordion for this category
    const categoryAccordion = document.getElementById(categoryId)
    if (categoryAccordion) {
      // Find and check the radio input to open the accordion
      const radioInput = categoryAccordion.querySelector('input[type="radio"]')
      if (radioInput) {
        radioInput.checked = true
      }

      // Wait for accordion to open, then scroll to the specific question
      setTimeout(() => {
        const targetElement = document.getElementById(hash)
        if (targetElement) {
          targetElement.scrollIntoView({ behavior: 'smooth', block: 'center' })

          // Briefly highlight the question
          targetElement.classList.add('bg-yellow-100')
          setTimeout(() => targetElement.classList.remove('bg-yellow-100'), 2000)
        }
      }, 100)
    }
  }
}
