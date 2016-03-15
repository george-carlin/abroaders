class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper

  # Placeholder page for root path
  def root
    if current_account
      if current_account.admin?
        render "admin/dashboard"
      else
        render "users/dashboard"
      end
    end
  end

end
