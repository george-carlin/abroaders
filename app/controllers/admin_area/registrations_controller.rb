module AdminArea
  class RegistrationsController < AdminController
    include Auth::Controllers::SignInOut

    def edit
      run Admin::Edit
      render cell(Admin::Cell::Edit, @model, form: @form)
    end

    def update
      run Admin::Update do
        flash[:notice] = I18n.t('devise.registrations.updated')
        sign_in :admin, @model, bypass: true
      end
      render cell(Admin::Cell::Edit, @model, form: @form)
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
