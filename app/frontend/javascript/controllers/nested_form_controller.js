import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    console.log('Nested form controller connected')
  }

  add(event) {
    event.preventDefault()

    // Clone the template
    const template = this.templateTarget
    const newFields = template.content.cloneNode(true)

    // Generate a unique timestamp-based ID for new records
    const timestamp = new Date().getTime()

    // Update all name and id attributes in the cloned fields
    // Replace placeholder NEW_RECORD with the timestamp
    this.updateAttributes(newFields, timestamp)

    // Insert the new fields into the container
    this.containerTarget.appendChild(newFields)

    console.log('Added new nested form fields')
  }

  updateAttributes(element, timestamp) {
    // Update all elements with name attributes
    element.querySelectorAll('[name]').forEach((field) => {
      const name = field.getAttribute('name')
      field.setAttribute('name', name.replace('NEW_RECORD', timestamp))
    })

    // Update all elements with id attributes
    element.querySelectorAll('[id]').forEach((field) => {
      const id = field.getAttribute('id')
      field.setAttribute('id', id.replace('NEW_RECORD', timestamp))
    })

    // Update all elements with for attributes (labels)
    element.querySelectorAll('[for]').forEach((field) => {
      const forAttr = field.getAttribute('for')
      field.setAttribute('for', forAttr.replace('NEW_RECORD', timestamp))
    })
  }
}
