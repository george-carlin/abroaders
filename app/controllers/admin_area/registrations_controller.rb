module AdminArea
  class RegistrationsController < AdminController
    include Auth::Controllers::SignInOut

    def edit
      render cell(Admin::Cell::Edit, current_admin)
    end

    def update
      if current_admin.update_with_password(update_params)
        flash[:notice] = I18n.t('devise.registrations.updated')
        sign_in :admin, current_admin, bypass: true
        redirect_to edit_admin_registration_path
      else
        current_admin.clean_up_passwords
        render cell(Admin::Cell::Edit, current_admin)
      end
    end

    private

    def auth_controller?
      true
    end

    def update_params
      params.require(:admin).permit(:password, :password_confirmation, :current_password)
    end
  end
end
