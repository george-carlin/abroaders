module SidebarHelper
  def sidebar?
    current_account&.onboarded? || current_admin.present?
  end
end
