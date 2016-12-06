module SidebarHelper
  def sidebar?
    current_account&.onboarded? || !current_admin.nil?
  end
end
