class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :stripe_session_id, presence: true, uniqueness: true
  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true
  validates :subtotal_amount, :vat_amount, :shipping_amount, :total_amount, 
            presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_name, :shipping_address_line1, :shipping_city, 
            :shipping_postal_code, :shipping_country, presence: true

  enum status: {
    pending: "pending",
    paid: "paid", 
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled",
    refunded: "refunded"
  }

  before_validation :generate_order_number, on: :create

  scope :recent, -> { order(created_at: :desc) }

  def items_count
    order_items.sum(:quantity)
  end

  def full_shipping_address
    address_parts = [
      shipping_address_line1,
      shipping_address_line2,
      shipping_city,
      shipping_postal_code,
      shipping_country
    ].compact

    address_parts.join(", ")
  end

  def display_number
    "##{order_number}"
  end

  private

  def generate_order_number
    return if order_number.present?
    
    loop do
      # Generate order number like: ORD-2025-001234
      year = Date.current.year
      random_part = SecureRandom.random_number(999999).to_s.rjust(6, '0')
      candidate = "ORD-#{year}-#{random_part}"
      
      unless Order.exists?(order_number: candidate)
        self.order_number = candidate
        break
      end
    end
  end
end
