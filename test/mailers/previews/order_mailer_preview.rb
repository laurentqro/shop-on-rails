class OrderMailerPreview < ActionMailer::Preview
  def confirmation_email
    OrderMailer.with(order: Order.last).confirmation_email
  end
end
