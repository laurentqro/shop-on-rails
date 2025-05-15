class Admin::ApplicationController < ApplicationController
  layout "admin"
  before_action :require_admin

  private

  def require_admin
    redirect_to root_path, alert: "You are not authorized to access this page." unless Current.user.admin?
  end
end