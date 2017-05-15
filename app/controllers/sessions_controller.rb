class SessionsController < ApplicationController
  prepend_before_action :require_no_authentication, only: [:new, :create]
  prepend_before_action(only: :create) { request.env["devise.allow_params_authentication"] = true }
  prepend_before_action :verify_signed_out_user, only: :destroy

  include SignInOut

  before_action :redirect_admins!

  layout 'basic'

  def new
    sign_in_params = if params[:account]
                       params.require(:account).permit(:email, :password)
                     else
                       {}
                     end
    account = Account.new(sign_in_params)
    account.clean_up_passwords
    render cell(Sessions::Cell::New, account)
  end

  # POST /resource/sign_in
  def create
    account = warden.authenticate!(scope: :account, recall: "#{controller_path}#new")
    flash[:notice] = I18n.t('devise.sessions.signed_in')
    sign_in(:account, account)
    redirect_to root_path
  end

  def destroy
    signed_out = sign_out_all_scopes
    flash[:notice] = I18n.t('devise.sessions.signed_out') if signed_out
    redirect_to root_path
  end

  private

  def redirect_admins!
    return unless current_admin
    flash[:notice] = "You must sign out of your admin account before "\
      "you can sign in as a regular user"
    redirect_to root_path
  end

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    if all_signed_out?
      flash[:notice] = I18n.t('devise.sessions.already_signed_out')
      redirect_to root_path
    end
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
  end

  # Helper for use in before_actions where no authentication is required.
  #
  # Example:
  #   before_action :require_no_authentication, only: :new
  def require_no_authentication
    if warden.authenticated?(:account) && warden.user(:account)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to root_path
    end
  end
end
