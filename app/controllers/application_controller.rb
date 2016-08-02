class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include CurrentUserHelper
  include I18nWithErrorRaising

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      @people = current_account.people.includes(
        :balances, :spending_info, card_accounts: :card
      ).order("main DESC")
      @travel_plans  = current_account.travel_plans.includes_destinations
      @unresolved_recommendations = current_account.card_recommendations.unresolved
      @recommendation_expiration = current_account.recommendations_expire_at
      render "accounts/dashboard"
    else
      redirect_to new_account_session_path
    end
  end

end
