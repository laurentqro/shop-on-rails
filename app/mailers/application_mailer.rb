class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("hello@afida.com", "Afida")
  layout "mailer"
end
