class OrderMailer < ApplicationMailer
  default from: "orders@#{Rails.application.credentials.dig(:mailgun, :domain)}"
  default bcc: "orders@#{Rails.application.credentials.dig(:mailgun, :domain)}"

  def confirmation_email(order)
    @order = order
    mail(to: @order.email, subject: "Your Order ##{@order.order_number} is Confirmed!")
  end
end 