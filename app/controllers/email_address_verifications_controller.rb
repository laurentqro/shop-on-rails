class EmailAddressVerificationsController < ApplicationController
  def show
    @user = User.find_by_email_address_verification_token!(params[:token])

    # Check if already verified before updating
    was_verified = @user.email_address_verified?
    @user.verify_email_address!

    # Send welcome email only if this is the first verification
    RegistrationMailer.welcome(@user).deliver_later unless was_verified

    redirect_to root_path, notice: "Your email address has been verified successfully. Welcome to Afida!", status: :see_other
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to root_path, notice: "Email confirmation link is invalid or has expired.", status: :unprocessable_entity
  end

  def create
    RegistrationMailer.verify_email_address(Current.user).deliver_later
  end
end
