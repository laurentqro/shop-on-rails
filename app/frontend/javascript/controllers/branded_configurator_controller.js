import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sizeOption",
    "quantityOption",
    "pricePerUnit",
    "savingsBadge",
    "totalPrice",
    "subtotal",
    "vat",
    "total",
    "addToCartButton",
    "designInput",
    "designPreview",
    "errorMessage"
  ]

  static values = {
    productId: Number,
    vatRate: { type: Number, default: 0.2 }
  }

  connect() {
    this.selectedSize = null
    this.selectedQuantity = null
    this.calculatedPrice = null
    this.updateAddToCartButton()

    // Auto-select first size and quantity for better UX
    if (this.sizeOptionTargets.length > 0) {
      this.sizeOptionTargets[0].click()
    }
    if (this.quantityOptionTargets.length > 0) {
      this.quantityOptionTargets[0].click()
    }
  }

  selectSize(event) {
    // Reset all size buttons to unselected state
    this.sizeOptionTargets.forEach(el => {
      el.classList.remove("border-primary", "border-4")
      el.classList.add("border-gray-300", "border-2")
    })

    // Add selected state to clicked button
    event.currentTarget.classList.remove("border-gray-300", "border-2")
    event.currentTarget.classList.add("border-primary", "border-4")

    this.selectedSize = event.currentTarget.dataset.size
    this.calculatePrice()
  }

  selectQuantity(event) {
    // Reset all quantity cards to unselected state
    this.quantityOptionTargets.forEach(el => {
      el.classList.remove("border-primary", "border-4")
      el.classList.add("border-gray-300", "border-2")
    })

    // Add selected state to clicked card
    event.currentTarget.classList.remove("border-gray-300", "border-2")
    event.currentTarget.classList.add("border-primary", "border-4")

    this.selectedQuantity = parseInt(event.currentTarget.dataset.quantity)
    this.calculatePrice()
  }

  async calculatePrice() {
    if (!this.selectedSize) {
      return
    }

    // Update all quantity cards with pricing for the selected size
    await this.updateAllQuantityPricing()

    // If a quantity is selected, update the summary
    if (this.selectedQuantity) {
      await this.updateSelectedQuantityPricing()
    }

    this.updateAddToCartButton()
  }

  async updateAllQuantityPricing() {
    // Get pricing for all quantity tiers
    const promises = this.quantityOptionTargets.map(async (card) => {
      const quantity = parseInt(card.dataset.quantity)

      try {
        const response = await fetch("/branded_products/calculate_price", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
          },
          body: JSON.stringify({
            product_id: this.productIdValue,
            size: this.selectedSize,
            quantity: quantity
          })
        })

        const data = await response.json()

        if (data.success) {
          // Find the targets within this card
          const priceTarget = card.querySelector('[data-branded-configurator-target="pricePerUnit"]')
          const totalTarget = card.querySelector('[data-branded-configurator-target="totalPrice"]')

          if (priceTarget) {
            priceTarget.textContent = `£${parseFloat(data.price_per_unit).toFixed(3)}/unit`
          }
          if (totalTarget) {
            const total = parseFloat(data.total_price) * (1 + this.vatRateValue)
            totalTarget.textContent = `£${total.toFixed(2)}`
          }

          // Store price per unit for savings calculation
          card.dataset.pricePerUnit = data.price_per_unit
        }
      } catch (error) {
        console.error("Failed to calculate price for quantity:", quantity, error)
      }
    })

    await Promise.all(promises)

    // Calculate and display savings relative to first tier
    if (this.quantityOptionTargets.length > 1) {
      const basePrice = parseFloat(this.quantityOptionTargets[0].dataset.pricePerUnit)

      this.quantityOptionTargets.forEach((card, index) => {
        if (index > 0 && card.dataset.pricePerUnit) {
          const cardPrice = parseFloat(card.dataset.pricePerUnit)
          const savingsPercent = Math.round(((basePrice - cardPrice) / basePrice) * 100)
          const savingsTarget = card.querySelector('[data-branded-configurator-target="savingsBadge"]')

          if (savingsTarget && savingsPercent > 0) {
            savingsTarget.textContent = `save ${savingsPercent}%`
            savingsTarget.classList.remove('invisible')
          }
        }
      })
    }
  }

  async updateSelectedQuantityPricing() {
    try {
      const response = await fetch("/branded_products/calculate_price", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({
          product_id: this.productIdValue,
          size: this.selectedSize,
          quantity: this.selectedQuantity
        })
      })

      const data = await response.json()

      if (data.success) {
        this.calculatedPrice = data.total_price
        this.updateSummaryDisplay(data)
        this.clearError()
      } else {
        this.showError(data.error)
      }
    } catch (error) {
      this.showError("Failed to calculate price. Please try again.")
    }
  }

  updateSummaryDisplay(data) {
    // Parse values as floats (server returns strings)
    const subtotal = parseFloat(data.total_price)

    // Update subtotal
    if (this.hasSubtotalTarget) {
      this.subtotalTarget.textContent = `£${subtotal.toFixed(2)}`
    }

    // Update VAT
    const vat = subtotal * this.vatRateValue
    if (this.hasVatTarget) {
      this.vatTarget.textContent = `£${vat.toFixed(2)}`
    }

    // Update total
    const total = subtotal + vat
    if (this.hasTotalTarget) {
      this.totalTarget.textContent = `£${total.toFixed(2)}`
    }
  }

  handleDesignUpload(event) {
    const file = event.target.files[0]
    if (!file) return

    // Validate file type
    const validTypes = ["application/pdf", "image/png", "image/jpeg", "application/postscript"]
    if (!validTypes.includes(file.type)) {
      this.showError("Please upload a PDF, PNG, JPG, or AI file")
      event.target.value = ""
      return
    }

    // Validate file size (max 10MB)
    const maxSize = 10 * 1024 * 1024
    if (file.size > maxSize) {
      this.showError("File size must be less than 10MB")
      event.target.value = ""
      return
    }

    // Show preview
    if (this.hasDesignPreviewTarget) {
      this.designPreviewTarget.textContent = file.name
      this.designPreviewTarget.classList.remove("hidden")
    }

    this.clearError()
    this.updateAddToCartButton()
  }

  updateAddToCartButton() {
    if (!this.hasAddToCartButtonTarget) return

    const isValid = this.selectedSize &&
                    this.selectedQuantity &&
                    this.calculatedPrice &&
                    this.designInputTarget?.files.length > 0

    this.addToCartButtonTarget.disabled = !isValid

    if (isValid) {
      this.addToCartButtonTarget.classList.remove("btn-disabled")
    } else {
      this.addToCartButtonTarget.classList.add("btn-disabled")
    }
  }

  showError(message) {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = message
      this.errorMessageTarget.classList.remove("hidden")
    }
  }

  clearError() {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.classList.add("hidden")
    }
  }

  async addToCart(event) {
    event.preventDefault()

    if (!this.selectedSize) {
      this.showError("Please select a size")
      return
    }

    if (!this.selectedQuantity) {
      this.showError("Please select a quantity")
      return
    }

    if (!this.designInputTarget?.files[0]) {
      this.showError("Please upload your design file")
      return
    }

    if (!this.calculatedPrice) {
      this.showError("Price calculation failed. Please try again")
      return
    }

    const formData = new FormData()
    formData.append("product_id", this.productIdValue)
    formData.append("configuration[size]", this.selectedSize)
    formData.append("configuration[quantity]", this.selectedQuantity)
    formData.append("calculated_price", this.calculatedPrice)

    if (this.designInputTarget.files[0]) {
      formData.append("design", this.designInputTarget.files[0])
    }

    try {
      const response = await fetch("/cart/cart_items", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: formData
      })

      if (response.ok) {
        // Turbo Stream will handle the updates and trigger the cart-drawer controller
        const text = await response.text()
        if (text) {
          Turbo.renderStreamMessage(text)

          // Dispatch turbo:submit-end event to trigger cart-drawer#open
          console.log('Dispatching turbo:submit-end event')
          const submitEndEvent = new CustomEvent("turbo:submit-end", {
            bubbles: true,
            detail: { success: true }
          })
          console.log('Event created:', submitEndEvent)
          this.element.dispatchEvent(submitEndEvent)
          console.log('Event dispatched from:', this.element)
        }
      } else {
        const data = await response.json()
        this.showError(data.error || "Failed to add to cart")
      }
    } catch (error) {
      this.showError("Failed to add to cart. Please try again.")
    }
  }
}
