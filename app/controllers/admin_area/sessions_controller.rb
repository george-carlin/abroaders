module AdminArea
  class SessionsController < Devise::SessionsController
    before_action :redirect_non_admins!

    layout 'basic'

    def new
      admin = Admin.new(sign_in_params)
      admin.clean_up_passwords
      render cell(Sessions::Cell::New, admin)
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
