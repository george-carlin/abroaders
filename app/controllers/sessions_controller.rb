class SessionsController < ApplicationController
  prepend_before_action only: [:new, :create] { require_no_authentication(:account) }
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
end
