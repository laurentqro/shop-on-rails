class Category < ApplicationRecord
  has_many :products
  has_one_attached :image

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def generate_slug
    if slug.blank? && name.present?
      self.slug = name.parameterize
    end
  end

  def to_param
    slug
  end
end
