class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      render "accounts/dashboard"
    end
  end

  def placeholder
    head :ok
  end

end
