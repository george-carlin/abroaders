class ApplicationController < ActionController::Base
  include Onboarding
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :warn_if_no_trb

  include I18nWithErrorRaising

  def dashboard
    if current_admin
      render "admin_area/dashboard"
    elsif current_account
      redirect_if_not_onboarded! && return

      unless current_account.has_any_recommendations?
        render("accounts/new_user_dashboard") && return
      end

      run(Account::Operation::Dashboard, {}, account: current_account)

      rec_timeout = cookies[:recommendation_timeout]

      render cell(Account::Cell::Dashboard, result, recommendation_timeout: rec_timeout)
    else
      redirect_to new_account_session_path
    end
  end

  private

  # extend the method provided by trailblazer so that it sets
  # @collection from result['collection'] (if collection is provided)
  #
  # TODO remove me
  def run(*args)
    result = super
    @collection = @_result['collection']
    result
  end

  def warn_if_no_trb
    # Enable this to help in the upgrade to Trailblazer
    if ENV['WARN_IF_NOT_TRB_OP'] && !@_run_called
      warn "#{self.class}##{params[:action]} needs upgrading to a TRB operation"
    end
  end
end
