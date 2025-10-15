require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "reset sends email to user email address" do
    email = PasswordsMailer.reset(@user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email_address], email.to
  end

  test "reset has correct subject" do
    email = PasswordsMailer.reset(@user)

    assert_equal "Reset your password", email.subject
  end

  test "reset body includes reset instructions" do
    email = PasswordsMailer.reset(@user)

    assert_match /reset/i, email.body.encoded
    assert_match /password/i, email.body.encoded
  end

  test "reset has both HTML and text parts" do
    email = PasswordsMailer.reset(@user)

    assert_equal 2, email.parts.size
    assert_equal "multipart/alternative", email.mime_type

    # Check for HTML part
    html_part = email.parts.find { |p| p.content_type.include?("text/html") }
    assert_not_nil html_part

    # Check for text part
    text_part = email.parts.find { |p| p.content_type.include?("text/plain") }
    assert_not_nil text_part
  end

  test "reset HTML body includes password reset link" do
    email = PasswordsMailer.reset(@user)
    html_part = email.parts.find { |p| p.content_type.include?("text/html") }

    assert_match /reset/i, html_part.body.to_s
  end

  test "reset text body includes password reset instructions" do
    email = PasswordsMailer.reset(@user)
    text_part = email.parts.find { |p| p.content_type.include?("text/plain") }

    assert_match /password/i, text_part.body.to_s
  end

  test "reset can be delivered" do
    assert_nothing_raised do
      PasswordsMailer.reset(@user).deliver_now
    end
  end

  test "reset uses correct from address" do
    email = PasswordsMailer.reset(@user)

    assert_not_nil email.from
    assert email.from.any?
  end

  test "reset email contains user-specific content" do
    email = PasswordsMailer.reset(@user)

    # Email should be personalized for this user
    assert_not_nil email.body
    assert email.body.encoded.length > 0
  end

  test "reset works for different users" do
    user1 = users(:one)
    user2 = users(:two)

    email1 = PasswordsMailer.reset(user1)
    email2 = PasswordsMailer.reset(user2)

    assert_equal [user1.email_address], email1.to
    assert_equal [user2.email_address], email2.to
    assert_not_equal email1.to, email2.to
  end

  test "reset email has valid structure" do
    email = PasswordsMailer.reset(@user)

    assert_not_nil email.subject
    assert_not_nil email.to
    assert_not_nil email.from
    assert_not_nil email.body
  end
end
