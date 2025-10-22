import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sizeOption",
    "finishOption",
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
    "errorMessage",
    "sizeIndicator",
    "finishIndicator",
    "quantityIndicator",
    "lidsIndicator",
    "designIndicator",
    "sizeStep",
    "finishStep",
    "quantityStep",
    "lidsStep",
    "designStep",
    "lidsContainer"
  ]

  static values = {
    productId: Number,
    vatRate: { type: Number, default: 0.2 },
    inModal: { type: Boolean, default: false }
  }

  connect() {
    this.selectedSize = null
    this.selectedFinish = null
    this.selectedQuantity = null
    this.calculatedPrice = null
    this.updateAddToCartButton()

    // Check for URL parameters and pre-select configuration
    this.loadFromUrlParams()
  }

  loadFromUrlParams() {
    const params = new URLSearchParams(window.location.search)

    // Pre-select size if in URL (normalize: "8 oz" or "8oz" → "8oz")
    const sizeParam = params.get('size')
    if (sizeParam) {
      const normalizedSize = sizeParam.replace(/\s+/g, '')
      const sizeButton = this.sizeOptionTargets.find(el =>
        el.dataset.size.replace(/\s+/g, '') === normalizedSize
      )
      if (sizeButton) {
        sizeButton.click()
      }
    }

    // Pre-select finish if in URL (normalize: "matte" → "Matt", "gloss" → "Gloss")
    const finishParam = params.get('finish')
    if (finishParam) {
      const normalizedFinish = finishParam.charAt(0).toUpperCase() + finishParam.slice(1).toLowerCase()
      const finishButton = this.finishOptionTargets.find(el =>
        el.dataset.finish.toLowerCase() === finishParam.toLowerCase()
      )
      if (finishButton) {
        finishButton.click()
      }
    }

    // Pre-select quantity if in URL
    const quantityParam = params.get('quantity')
    if (quantityParam) {
      const quantity = parseInt(quantityParam)
      const quantityCard = this.quantityOptionTargets.find(el =>
        parseInt(el.dataset.quantity) === quantity
      )
      if (quantityCard) {
        quantityCard.click()
      }
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
    this.updateUrl()
    this.showStepComplete('size')
    this.calculatePrice()
  }

  selectFinish(event) {
    // Reset all finish buttons to unselected state
    this.finishOptionTargets.forEach(el => {
      el.classList.remove("border-primary", "border-4")
      el.classList.add("border-gray-300", "border-2")
    })

    // Add selected state to clicked button
    event.currentTarget.classList.remove("border-gray-300", "border-2")
    event.currentTarget.classList.add("border-primary", "border-4")

    this.selectedFinish = event.currentTarget.dataset.finish
    this.updateUrl()
    this.showStepComplete('finish')
    this.updateAddToCartButton()
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
    this.updateUrl()
    this.showStepComplete('quantity')

    // Load compatible lids for next step (skip in modal mode)
    if (!this.inModalValue) {
      this.loadCompatibleLids()
    }

    this.calculatePrice()
  }

  async loadCompatibleLids() {
    if (!this.selectedSize) return

    // Show loading state
    document.getElementById('lids-loading').style.display = 'block'
    this.lidsContainerTarget.innerHTML = ''

    try {
      const response = await fetch(`/branded_products/compatible_lids?size=${this.selectedSize}`)
      const data = await response.json()

      document.getElementById('lids-loading').style.display = 'none'

      if (data.lids.length === 0) {
        this.lidsContainerTarget.innerHTML = '<p class="text-gray-500 col-span-full text-center py-8">No compatible lids available for this size</p>'
        return
      }

      // Render lid cards
      data.lids.forEach(lid => {
        this.lidsContainerTarget.appendChild(this.createLidCard(lid))
      })
    } catch (error) {
      console.error('Failed to load compatible lids:', error)
      document.getElementById('lids-loading').style.display = 'none'
      this.lidsContainerTarget.innerHTML = '<p class="text-error col-span-full text-center py-8">Failed to load lids. Please try again.</p>'
    }
  }

  createLidCard(lid) {
    const card = document.createElement('div')
    card.className = 'card bg-white border-2 border-gray-200 hover:border-primary transition'
    card.innerHTML = `
      <figure class="p-4">
        ${lid.image_url ?
          `<img src="${lid.image_url}" alt="${lid.name}" class="w-full h-32 object-contain" />` :
          '<div class="w-full h-32 bg-gray-100 flex items-center justify-center"><span class="text-4xl">📦</span></div>'
        }
      </figure>
      <div class="card-body p-4">
        <h3 class="card-title text-sm">${lid.name}</h3>
        <p class="text-lg font-bold">£${parseFloat(lid.price).toFixed(2)}</p>
        <p class="text-xs text-gray-500">Pack of ${lid.pac_size.toLocaleString()}</p>

        <select class="select select-sm select-bordered w-full mt-2" data-lid-quantity="${lid.sku}">
          ${this.generateLidQuantityOptions(lid.pac_size, this.selectedQuantity).map(q =>
            `<option value="${q.value}">${q.label}</option>`
          ).join('')}
        </select>

        <button class="btn btn-primary btn-sm mt-2"
                data-action="click->branded-configurator#addLidToCart"
                data-lid-sku="${lid.sku}"
                data-lid-name="${lid.name}">
          + Add
        </button>
      </div>
    `
    return card
  }

  generateLidQuantityOptions(pac_size, cupQuantity) {
    // Generate pack multiples up to 10 packs
    const options = []
    for (let i = 1; i <= 10; i++) {
      const quantity = pac_size * i
      const numPacks = i
      options.push({
        value: quantity,
        label: `${quantity.toLocaleString()} units (${numPacks} ${numPacks === 1 ? 'pack' : 'packs'})`,
        selected: quantity === cupQuantity
      })
    }
    return options
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
    this.showStepComplete('design')
    this.updateAddToCartButton()
  }

  updateUrl() {
    const params = new URLSearchParams(window.location.search)

    // Update URL parameters based on current selections
    if (this.selectedSize) {
      params.set('size', this.selectedSize)
    }
    if (this.selectedFinish) {
      params.set('finish', this.selectedFinish)
    }
    if (this.selectedQuantity) {
      params.set('quantity', this.selectedQuantity)
    }

    // Update browser URL without page reload
    const newUrl = `${window.location.pathname}?${params.toString()}`
    window.history.replaceState({}, '', newUrl)
  }

  showStepComplete(step) {
    const indicatorTarget = `${step}IndicatorTarget`
    if (this[indicatorTarget]) {
      // Transform to checkmark
      this[indicatorTarget].textContent = '✓'
      this[indicatorTarget].classList.remove('bg-gray-300')
      this[indicatorTarget].classList.add('bg-success')
    }

    // Open next step in accordion
    // In modal mode, skip lids step and go directly from quantity to design
    const stepMap = this.inModalValue
      ? { size: 'finish', finish: 'quantity', quantity: 'design', design: null }
      : { size: 'finish', finish: 'quantity', quantity: 'lids', lids: 'design' }

    const nextStep = stepMap[step]
    if (nextStep) {
      const nextStepTarget = `${nextStep}StepTarget`
      if (this[nextStepTarget]) {
        const radioInput = this[nextStepTarget].querySelector('input[type="radio"]')
        if (radioInput) {
          radioInput.checked = true
        }
      }
    }
  }

  skipLids(event) {
    // Mark step complete and move to design
    this.showStepComplete('lids')
  }

  async addLidToCart(event) {
    const button = event.currentTarget
    const sku = button.dataset.lidSku
    const name = button.dataset.lidName
    const quantitySelect = button.closest('.card-body').querySelector('select')
    const quantity = parseInt(quantitySelect.value)

    // Disable button during request
    button.disabled = true
    button.textContent = 'Adding...'

    try {
      const response = await fetch("/cart/cart_items", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: JSON.stringify({
          cart_item: {
            variant_sku: sku,
            quantity: quantity
          }
        })
      })

      if (response.ok) {
        // Process turbo stream to update basket counter
        const text = await response.text()
        if (text) {
          Turbo.renderStreamMessage(text)
        }

        // Show success feedback
        button.textContent = '✓ Added'
        button.classList.remove('btn-primary')
        button.classList.add('btn-success')

        // Reset after 2 seconds
        setTimeout(() => {
          button.textContent = '+ Add'
          button.classList.remove('btn-success')
          button.classList.add('btn-primary')
          button.disabled = false
        }, 2000)
      } else {
        throw new Error('Failed to add lid')
      }
    } catch (error) {
      this.showError(`Failed to add ${name}`)
      button.disabled = false
      button.textContent = '+ Add'
    }
  }

  updateAddToCartButton() {
    if (!this.hasAddToCartButtonTarget) return

    const isValid = this.selectedSize &&
                    this.selectedFinish &&
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

    if (!this.selectedFinish) {
      this.showError("Please select a finish")
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
    formData.append("configuration[finish]", this.selectedFinish)
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

          if (this.inModalValue) {
            // In modal: dispatch event to close modal
            window.dispatchEvent(new CustomEvent('addon:added'))
          } else {
            // Normal flow: open drawer
            console.log('Dispatching turbo:submit-end event')
            const submitEndEvent = new CustomEvent("turbo:submit-end", {
              bubbles: true,
              detail: { success: true }
            })
            console.log('Event created:', submitEndEvent)
            this.element.dispatchEvent(submitEndEvent)
            console.log('Event dispatched from:', this.element)
          }
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
