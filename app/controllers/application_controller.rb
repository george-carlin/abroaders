class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper

  # Placeholder page for root path
  def root
    if current_admin
      render "admin/dashboard"
    elsif current_account
      render "accounts/dashboard"
    end
  end

end
