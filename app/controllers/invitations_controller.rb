class InvitationsController < Devise::InvitationsController
  before_action :redirect_non_admins!, only: [:new, :create]
  before_action :redirect_admins!, only: [:edit, :update]
  before_action :configure_permitted_parameters

  layout "basic", only: [:edit, :update]

  private

  def after_accept_path_for(resource)
    resource.onboarding_survey.current_page.path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite) do |account|
      account.permit(:email, owner_attributes: :first_name, companion_attributes: [:first_name, :main])
    end
  end

  def authenticate_inviter!
    authenticate_admin!(force: true)
  end

  def redirect_admins!
    if current_admin
      flash[:notice] = "You must sign out of your admin account before "\
                       "you can sign in as a regular user"
      redirect_to root_path
    end
  end

  def redirect_non_admins!
    if current_account
      flash[:notice] = "You must sign out of your regular account before "\
                           "you can sign in as an admin"
      redirect_to root_path
    end
  end
end
