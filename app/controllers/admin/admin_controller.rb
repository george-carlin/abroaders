module Admin
  class AdminController < ::ApplicationController

    before_action { redirect_to root_path unless current_user.try(:admin?) }
  end
end
