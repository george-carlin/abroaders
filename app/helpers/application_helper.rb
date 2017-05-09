module ApplicationHelper
  include BootstrapOverrides

  def current_user
    current_admin || current_account
  end
end
