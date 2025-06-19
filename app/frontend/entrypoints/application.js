// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

// Start Stimulus application
const application = Application.start()

// Import all controllers
import CartDrawerController from "../javascript/controllers/cart_drawer_controller"
application.register("cart-drawer", CartDrawerController)

import CarouselController from "../javascript/controllers/carousel_controller"
application.register("carousel", CarouselController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

//
import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
