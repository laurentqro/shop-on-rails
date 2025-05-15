class Admin::ApplicationController < ApplicationController
  layout "admin"
  allow_unauthenticated_access
end