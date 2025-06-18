class RegistrationMailer < ApplicationMailer
  def verify_email_address(user)
    @user = user

    mail(
      to: user.email_address,
      subject: "Verify your email address"
    )
  end
end
