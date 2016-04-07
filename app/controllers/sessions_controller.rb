class SessionsController < Devise::SessionsController
  before_action :redirect_admins!

  private

  def redirect_admins!
    if current_admin
      flash[:notice] = "You must sign out of your admin account before "\
                       "you can sign in as a regular user"
      redirect_to root_path
    end
  end
end
