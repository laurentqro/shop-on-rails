class Product < ApplicationRecord
  default_scope { where(active: true) }
  scope :featured, -> { where(featured: true) }

  belongs_to :category

  has_one_attached :image

  before_validation :generate_slug

  validates :name, :price, :category, :sku, presence: true
  validates :sku, uniqueness: true
  validates :price, numericality: { greater_than: 0 }
  validates :slug, presence: true, uniqueness: true

  def generate_slug
    if slug.blank? && name.present? && sku.present?
      self.slug = "#{sku} #{name}".parameterize
    end
  end

  def to_param
    slug
  end
end
