import { Controller } from "@hotwired/stimulus"

// Handles separate Size/Color option selection on product pages
// Finds matching variant based on selected options
export default class extends Controller {
  static targets = ["sizeSelect", "colorSelect", "priceDisplay", "imageDisplay", "variantSkuInput"]

  static values = {
    variants: Array  // All product variants with their option_values
  }

  connect() {
    console.log("Product options controller connected")
    console.log("Variants:", this.variantsValue)
  }

  updateSelection() {
    const selectedSize = this.hasSizeSelectTarget ? this.sizeSelectTarget.value : null
    const selectedColor = this.hasColorSelectTarget ? this.colorSelectTarget.value : null

    console.log("Selected:", { size: selectedSize, color: selectedColor })

    // Find matching variant
    const matchingVariant = this.findMatchingVariant(selectedSize, selectedColor)

    if (matchingVariant) {
      this.updateDisplay(matchingVariant)
    } else {
      console.warn("No matching variant found")
    }
  }

  findMatchingVariant(size, color) {
    return this.variantsValue.find(variant => {
      const sizeMatch = !size || variant.option_values.Size === size
      const colorMatch = !color || variant.option_values.Color === color
      return sizeMatch && colorMatch
    })
  }

  updateDisplay(variant) {
    console.log("Updating display for variant:", variant)

    // Update price
    if (this.hasPriceDisplayTarget) {
      const formatter = new Intl.NumberFormat('en-GB', {
        style: 'currency',
        currency: 'GBP'
      })
      this.priceDisplayTarget.textContent = formatter.format(variant.price)
    }

    // Update hidden SKU input for cart form
    if (this.hasVariantSkuInputTarget) {
      this.variantSkuInputTarget.value = variant.sku
    }

    // Update image if variant has one
    if (this.hasImageDisplayTarget && variant.image_url) {
      this.imageDisplayTarget.src = variant.image_url
    }

    // Update URL to reflect selection (optional)
    this.updateUrl(variant)
  }

  updateUrl(variant) {
    const params = new URLSearchParams(window.location.search)
    params.set('variant_id', variant.id)
    const newUrl = `${window.location.pathname}?${params.toString()}`
    window.history.replaceState({}, '', newUrl)
  }
}
