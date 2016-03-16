module SessionsHelper

  def link_to_sign_out
    path = if current_admin
             destroy_admin_session_path
           else
             destroy_account_session_path
           end
    link_to "Sign out", path, method: :delete
  end

end
