class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :customized_products, -> { where(product_type: "customized_instance") },
           class_name: "Product",
           foreign_key: :organization_id,
           dependent: :restrict_with_error

  validates :name, presence: true
  validates :billing_email, presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }

  def owner
    users.find_by(role: "owner")
  end
end
