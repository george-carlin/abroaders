module AdminArea
  class SessionsController < ApplicationController
    prepend_before_action only: [:new, :create] { require_no_authentication(:admin) }
    prepend_before_action(only: :create) { request.env["devise.allow_params_authentication"] = true }
    prepend_before_action :verify_signed_out_user, only: :destroy
    before_action :redirect_non_admins!

    include SignInOut

    layout 'basic'

    def new
      sign_in_params = if params[:admin]
                         params.require(:admin).permit(:email, :password)
                       else
                         {}
                       end
      admin = Admin.new(sign_in_params)
      admin.clean_up_passwords
      render cell(Sessions::Cell::New, admin)
    end

    def create
      admin = warden.authenticate!(scope: :admin, recall: "#{controller_path}#new")
      flash[:notice] = I18n.t('devise.sessions.signed_in')
      sign_in(:admin, admin)
      redirect_to root_path
    end

    def destroy
      signed_out = sign_out_all_scopes
      flash[:notice] = I18n.t('devise.sessions.signed_out') if signed_out
      redirect_to root_path
    end

    private

    def redirect_non_admins!
      return unless current_account
      flash[:notice] = "You must sign out of your regular account before "\
        "you can sign in as an admin"
      redirect_to root_path
    end
  end
end
