import { Controller } from "@hotwired/stimulus"

// Handles Size/Colour option selection on product pages with button selectors
// Finds matching variant based on selected options
export default class extends Controller {
  static targets = ["sizeButton", "colourButton", "priceDisplay", "imageDisplay", "variantSkuInput"]

  static values = {
    variants: Array  // All product variants with their option_values
  }

  connect() {
    // Read URL parameters
    const params = new URLSearchParams(window.location.search)
    const urlSize = params.get('size')
    const urlColour = params.get('colour')

    // Pre-select size button based on URL parameter or default to first
    if (this.hasSizeButtonTarget) {
      let buttonToSelect = this.sizeButtonTargets[0]

      if (urlSize) {
        const matchingButton = this.sizeButtonTargets.find(btn =>
          btn.dataset.value === urlSize
        )
        if (matchingButton) {
          buttonToSelect = matchingButton
        }
      }

      this.selectButtonVisual(buttonToSelect)
    }

    // Pre-select colour button based on URL parameter or default to first
    if (this.hasColourButtonTarget) {
      let buttonToSelect = this.colourButtonTargets[0]

      if (urlColour) {
        const matchingButton = this.colourButtonTargets.find(btn =>
          btn.dataset.value === urlColour
        )
        if (matchingButton) {
          buttonToSelect = matchingButton
        }
      }

      this.selectButtonVisual(buttonToSelect)
    }

    // Update selection to show correct variant on page load
    this.updateSelection()
  }

  selectSize(event) {
    // Deselect all size buttons
    this.sizeButtonTargets.forEach(btn => this.deselectButtonVisual(btn))
    // Select clicked button
    this.selectButtonVisual(event.currentTarget)
    // Update variant display
    this.updateSelection()
  }

  selectColour(event) {
    // Deselect all colour buttons
    this.colourButtonTargets.forEach(btn => this.deselectButtonVisual(btn))
    // Select clicked button
    this.selectButtonVisual(event.currentTarget)
    // Update variant display
    this.updateSelection()
  }

  selectButtonVisual(button) {
    button.classList.remove('border-gray-300')
    button.classList.add('border-primary')
    // Show checkmark
    const checkmark = button.querySelector('.option-checkmark')
    if (checkmark) {
      checkmark.classList.remove('hidden')
    }
  }

  deselectButtonVisual(button) {
    button.classList.remove('border-primary')
    button.classList.add('border-gray-300')
    // Hide checkmark
    const checkmark = button.querySelector('.option-checkmark')
    if (checkmark) {
      checkmark.classList.add('hidden')
    }
  }

  updateSelection() {
    const selectedSize = this.getSelectedValue(this.sizeButtonTargets)
    const selectedColour = this.getSelectedValue(this.colourButtonTargets)

    // Find matching variant
    const matchingVariant = this.findMatchingVariant(selectedSize, selectedColour)

    if (matchingVariant) {
      this.updateDisplay(matchingVariant)
    }
  }

  getSelectedValue(buttons) {
    if (!buttons || buttons.length === 0) return null
    const selectedButton = buttons.find(btn =>
      btn.classList.contains('border-primary')
    )
    return selectedButton ? selectedButton.dataset.value : null
  }

  findMatchingVariant(size, colour) {
    return this.variantsValue.find(variant => {
      const sizeMatch = !size || variant.option_values.Size === size
      const colourMatch = !colour || variant.option_values.Colour === colour
      return sizeMatch && colourMatch
    })
  }

  updateDisplay(variant) {
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

    // Set size parameter if variant has size
    if (variant.option_values.Size) {
      params.set('size', variant.option_values.Size)
    } else {
      params.delete('size')
    }

    // Set colour parameter if variant has colour
    if (variant.option_values.Colour) {
      params.set('colour', variant.option_values.Colour)
    } else {
      params.delete('colour')
    }

    const newUrl = `${window.location.pathname}?${params.toString()}`
    window.history.replaceState({}, '', newUrl)
  }
}
