class RegistrationsController < ApplicationController
  # If Authentication concern is not in ApplicationController, include it:
  # include Authentication
  # Or, if it's already in ApplicationController, ensure this controller allows unauthenticated access for new/create
  allow_unauthenticated_access only: [ :new, :create ] # Use this if Authentication concern's before_action :require_authentication is in ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      RegistrationMailer.verify_email_address(@user).deliver_later

      redirect_to root_path, notice: "Please check your email for verification instructions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
