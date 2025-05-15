class Product < ApplicationRecord
  default_scope { where(active: true) }
  belongs_to :category

  has_one_attached :image

  validates :name, :description, :price, :category, presence: true
  validates :price, numericality: { greater_than: 0 }
end