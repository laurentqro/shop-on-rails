import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sizeOption",
    "quantityOption",
    "pricePerUnit",
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
  }

  selectSize(event) {
    // Remove active class from all size options
    this.sizeOptionTargets.forEach(el => {
      el.classList.remove("btn-primary")
      el.classList.add("btn-outline")
    })

    // Add active class to selected
    event.currentTarget.classList.remove("btn-outline")
    event.currentTarget.classList.add("btn-primary")

    this.selectedSize = event.currentTarget.dataset.size
    this.calculatePrice()
  }

  selectQuantity(event) {
    // Remove active class from all quantity options
    this.quantityOptionTargets.forEach(el => {
      el.classList.remove("card-bordered", "border-primary")
      el.classList.add("border-base-300")
    })

    // Add active class to selected
    event.currentTarget.classList.remove("border-base-300")
    event.currentTarget.classList.add("card-bordered", "border-primary")

    this.selectedQuantity = parseInt(event.currentTarget.dataset.quantity)
    this.calculatePrice()
  }

  async calculatePrice() {
    if (!this.selectedSize || !this.selectedQuantity) {
      return
    }

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
        this.updatePricingDisplay(data)
        this.clearError()
      } else {
        this.showError(data.error)
      }
    } catch (error) {
      this.showError("Failed to calculate price. Please try again.")
    }

    this.updateAddToCartButton()
  }

  updatePricingDisplay(data) {
    // Update price per unit
    if (this.hasPricePerUnitTarget) {
      this.pricePerUnitTarget.textContent = `£${data.price_per_unit.toFixed(2)}`
    }

    // Update subtotal
    const subtotal = data.total_price
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

    // Update total price display
    if (this.hasTotalPriceTarget) {
      this.totalPriceTarget.textContent = `£${total.toFixed(2)}`
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

    if (!this.selectedSize || !this.selectedQuantity || !this.calculatedPrice) {
      this.showError("Please complete all configuration steps")
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
      const response = await fetch("/cart_items", {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: formData
      })

      if (response.ok) {
        // Redirect to cart or show success
        window.location.href = "/cart"
      } else {
        const data = await response.json()
        this.showError(data.error || "Failed to add to cart")
      }
    } catch (error) {
      this.showError("Failed to add to cart. Please try again.")
    }
  }
}
