class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      @people = current_account.people.includes(
        :balances, :spending_info, card_accounts: :card
      ).order("main DESC")
      @travel_plans  = current_account.travel_plans
      render "accounts/dashboard"
    end
  end

end
