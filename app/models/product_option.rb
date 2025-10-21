class ProductOption < ApplicationRecord
  has_many :values, -> { order(:position) },
           class_name: "ProductOptionValue",
           dependent: :destroy
  has_many :assignments, class_name: "ProductOptionAssignment", dependent: :destroy
  has_many :products, through: :assignments

  enum :display_type, { dropdown: "dropdown", radio: "radio", swatch: "swatch" }, validate: true

  validates :name, presence: true
  validates :display_type, presence: true

  default_scope { order(:position) }
end
