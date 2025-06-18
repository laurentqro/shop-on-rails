class RegistrationMailer < ApplicationMailer
  default bcc: "hello@afida.com"

  def verify_email_address(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Verify your email address"
    )
  end

  def welcome(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Welcome to Afida!"
    )
  end
end
