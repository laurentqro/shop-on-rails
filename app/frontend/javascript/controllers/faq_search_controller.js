import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const query = this.inputTarget.value

      if (query.length >= 2) {
        this.element.requestSubmit()
      } else if (query.length === 0) {
        // Clear search by submitting empty form
        this.element.requestSubmit()
      }
    }, this.debounceValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
