class RegistrationsController < Devise::RegistrationsController
  layout "basic"
  include Onboarding

  def new
    @form = SignUp.new(promo_code: params[:promo_code])
    set_minimum_password_length
  end

  def create
    @form = SignUp.new(sign_up_params)

    if @form.save
      AccountMailer.notify_admin_of_sign_up(@form.account.id).deliver_later
      create_intercom_user!(@form.account)
      set_flash_message! :notice, :signed_up
      sign_in(:account, @form.account)
      respond_with resource, location: onboarding_survey_path
    else
      @form.clean_up_passwords
      set_minimum_password_length
      render "new"
    end
  end

  protected

  def create_intercom_user!(account)
    IntercomJobs::CreateUser.perform_later(
      'email'        => account.email,
      'name'         => account.owner.first_name,
      'signed_up_at' => account.created_at.to_i,
    )
  end

  def set_minimum_password_length
    @minimum_password_length = Account.password_length.min
  end

  def sign_up_params
    params.require(:sign_up).permit(
      :email, :first_name, :password, :password_confirmation,
      :promo_code,
    )
  end
end
