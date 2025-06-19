import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"
import { Navigation, Pagination, Autoplay } from "swiper/modules"

export default class extends Controller {
  connect() {
    console.log("Carousel controller connected")
    this.swiper = new Swiper(this.element, {
      modules: [Navigation, Pagination, Autoplay],
      loop: true,
      pagination: {
        el: ".swiper-pagination",
        clickable: true,
      },
      navigation: {
        nextEl: ".swiper-button-next",
        prevEl: ".swiper-button-prev",
      },
      autoplay: {
        delay: 5000,
        disableOnInteraction: false,
      },
    })
  }
} 