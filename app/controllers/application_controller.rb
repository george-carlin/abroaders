class ApplicationController < ActionController::Base
  include Onboarding
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include I18nWithErrorRaising

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      redirect_if_not_onboarded! && return

      @account = current_account
      unless @account.has_any_recommendations?
        render("accounts/new_user_dashboard") && return
      end

      @people = @account.people.includes(
        :balances, :spending_info, card_accounts: :card,
      ).order(owner: :desc)
      @travel_plans = current_account.travel_plans.includes_destinations
      @unresolved_recommendations = current_account.card_recommendations.unresolved
      @recommendation_expiration = current_account.recommendations_expire_at

      render "accounts/dashboard"
    else
      redirect_to new_account_session_path
    end
  end
end
