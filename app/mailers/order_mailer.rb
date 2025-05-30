class OrderMailer < ApplicationMailer
  default bcc: "orders@afida.com"

  def confirmation_email
    @order = params[:order]
    mail(to: @order.email, subject: "Your Order ##{@order.order_number} is Confirmed!")
  end
end 