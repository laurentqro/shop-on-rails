import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"
import { Navigation, Pagination, Autoplay } from "swiper/modules"

export default class extends Controller {
  connect() {
    console.log("Carousel controller connected")

    // Check if this is an addon carousel (multiple slides per view)
    const isAddonCarousel = this.element.classList.contains('addon-carousel')

    // Count slides to determine if loop should be enabled
    const slideCount = this.element.querySelectorAll('.swiper-slide').length

    const config = {
      modules: [Navigation, Pagination, Autoplay],
      loop: slideCount > 3, // Only loop if enough slides
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
      autoplay: slideCount > 1 ? {
        delay: 5000,
        disableOnInteraction: false,
      } : false, // Disable autoplay if only 1 slide
    }

    // Add responsive breakpoints for addon carousel
    if (isAddonCarousel) {
      config.slidesPerView = 1
      config.spaceBetween = 20
      config.breakpoints = {
        640: {
          slidesPerView: 1,
          spaceBetween: 20,
        },
        768: {
          slidesPerView: 2,
          spaceBetween: 20,
        },
        1024: {
          slidesPerView: 3,
          spaceBetween: 30,
        },
      }
    }

    this.swiper = new Swiper(this.element, config)
  }
} 