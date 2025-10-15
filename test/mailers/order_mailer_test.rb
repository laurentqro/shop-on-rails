require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:one)
  end

  test "confirmation_email sends email to order email address" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@order.email], email.to
  end

  test "confirmation_email has correct subject with order number" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_equal "Your Order ##{@order.order_number} is Confirmed!", email.subject
  end

  test "confirmation_email includes BCC to orders email" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_includes email.bcc, "orders@afida.com"
  end

  test "confirmation_email body includes order number" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_match @order.order_number, email.body.encoded
  end

  test "confirmation_email body includes shipping name" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_match @order.shipping_name, email.body.encoded
  end

  test "confirmation_email has both HTML and text parts" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_equal 2, email.parts.size
    assert_equal "multipart/alternative", email.mime_type

    # Check for HTML part
    html_part = email.parts.find { |p| p.content_type.include?("text/html") }
    assert_not_nil html_part

    # Check for text part
    text_part = email.parts.find { |p| p.content_type.include?("text/plain") }
    assert_not_nil text_part
  end

  test "confirmation_email HTML body includes order details" do
    email = OrderMailer.with(order: @order).confirmation_email
    html_part = email.parts.find { |p| p.content_type.include?("text/html") }

    assert_match @order.order_number, html_part.body.to_s
    assert_match @order.shipping_name, html_part.body.to_s
  end

  test "confirmation_email text body includes order number" do
    email = OrderMailer.with(order: @order).confirmation_email
    text_part = email.parts.find { |p| p.content_type.include?("text/plain") }

    assert_match @order.order_number, text_part.body.to_s
  end

  test "confirmation_email includes order total" do
    email = OrderMailer.with(order: @order).confirmation_email

    # Format as currency
    total = sprintf("%.2f", @order.total_amount)
    assert_match total, email.body.encoded
  end

  test "confirmation_email can be delivered" do
    assert_nothing_raised do
      OrderMailer.with(order: @order).confirmation_email.deliver_now
    end
  end

  test "confirmation_email uses correct from address" do
    email = OrderMailer.with(order: @order).confirmation_email

    assert_not_nil email.from
    assert email.from.any?
  end

  test "confirmation_email with order that has items" do
    # Order fixture should have order_items
    assert @order.order_items.any?, "Order fixture should have items"

    email = OrderMailer.with(order: @order).confirmation_email

    # Email should be generated successfully
    assert_not_nil email
    assert_equal [@order.email], email.to
  end
end
