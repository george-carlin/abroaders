module AdminArea
  class AdminController < ::ApplicationController
    before_action :authenticate_admin!
    before_action :simultaneous_login!

    private

    # If an admin is currently using the 'log in as user' feature, they must
    # exit that user's account before they can go back to doing normal admin
    # functions
    def simultaneous_login!
      redirect_to root_path if current_admin && current_account
    end
  end
end
