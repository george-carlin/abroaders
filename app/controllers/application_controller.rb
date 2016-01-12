class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Placeholder page for root path
  def root
    if current_user
      if current_user.admin?
        render "admin/dashboard"
      else
        @card_accounts = current_user.card_accounts
        render "users/dashboard"
      end
    end
  end

end
