module AdminHelper

  def admin_page?
    current_admin || devise_controller? && resource_name && resource_name == :admin
  end

end
