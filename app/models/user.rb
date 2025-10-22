class User < ApplicationRecord
  include EmailAddressVerification
  has_email_address_verification

  has_secure_password

  belongs_to :organization, optional: true
  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true

  enum :role, { owner: "owner", admin: "admin", member: "member" }, validate: { allow_nil: true }

  validates :role, presence: true, if: :organization_id?
  validate :organization_has_one_owner, if: -> { organization_id? && role == "owner" }

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

  private

  def organization_has_one_owner
    return unless organization

    existing_owner = organization.users.where(role: "owner").where.not(id: id).exists?
    if existing_owner
      errors.add(:role, "organization already has an owner")
    end
  end
end
