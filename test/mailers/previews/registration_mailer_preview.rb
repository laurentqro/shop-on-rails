class RegistrationMailerPreview < ActionMailer::Preview
  def verify_email_address
    RegistrationMailer.verify_email_address(User.first)
  end

  def welcome
    RegistrationMailer.welcome(User.first)
  end
end