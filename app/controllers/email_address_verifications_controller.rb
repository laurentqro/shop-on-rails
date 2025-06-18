class EmailAddressVerificationsController < ApplicationController
  def show
    @user = User.find_by_email_address_verification_token!(params[:token])
    @user.verify_email_address!
    RegistrationMailer.welcome(@user).deliver_later

    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to root_path, notice: "Email confirmation link is invalid or has expired.", status: :unprocessable_entity

    redirect_to root_path, notice: "Your email address has been verified successfully. Welcome to Afida!", status: :see_other
  end

  def create
    RegistrationMailer.verify_email_address(Current.user).deliver_later
  end
end
