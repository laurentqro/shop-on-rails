class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    role == "admin"
  end
end
