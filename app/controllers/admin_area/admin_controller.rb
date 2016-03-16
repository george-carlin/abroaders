module AdminArea
  class AdminController < ::AuthenticatedController

    before_action { redirect_to root_path unless current_account.try(:admin?) }
  end
end
