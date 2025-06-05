class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    role == "admin"
  end

  def initials
    if [first_name, last_name].all?(&:present?)
      first_name.first.upcase + last_name.first.upcase
    else
      email_address.split("@").first.split(".").map(&:first).join.upcase
    end
  end
end