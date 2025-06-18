class User < ApplicationRecord
  include EmailAddressVerification
  has_email_address_verification

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end

  def initials
    if [ first_name, last_name ].all?(&:present?)
      first_name.first.upcase + last_name.first.upcase
    else
      email_address.split("@").first.split(".").map(&:first).join.upcase
    end
  end

  def verify_email_address!
    update!(email_address_verified: true)
  end

  def email_address_verification_token_expired?
    email_address_verification_token_expires_at < Time.current
  end
end
