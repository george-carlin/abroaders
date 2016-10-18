module SessionsHelper
  def sign_out_path
    current_admin ? destroy_admin_session_path : destroy_account_session_path
  end
end
