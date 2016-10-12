class RegistrationsController < Devise::RegistrationsController

  layout "basic"

  def new
    @form = SignUp.new
    set_minimum_password_length
  end

  def create
    @form = SignUp.new(sign_up_params)

    if @form.save
      AccountMailer.notify_admin_of_sign_up(@form.account.id).deliver_later
      IntercomJobs::CreateUser.perform_later(account_id: @form.account.id)
      set_flash_message! :notice, :signed_up
      sign_in(:account, @form.account)
      respond_with resource, location: @form.account.onboarding_survey.current_path
    else
      @form.clean_up_passwords
      set_minimum_password_length
      render "new"
    end
  end

  protected

  def set_minimum_password_length
    @minimum_password_length = Account.password_length.min
  end

  def sign_up_params
    params.require(:sign_up).permit(
      :email, :first_name, :password, :password_confirmation
      # Use to_h or Virtus will call to_hash by default, which raises a
      # deprecation warning:
    ).to_h
  end

end
