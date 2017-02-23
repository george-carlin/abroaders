class RegistrationsController < Devise::RegistrationsController
  layout "basic"
  include Onboarding

  def new
    @form = Registration::SignUpForm.new
    set_minimum_password_length
  end

  def create
    @form = Registration::SignUpForm.new

    if @form.validate(params[:account])
      @form.save
      account = @form.model
      AccountMailer.notify_admin_of_sign_up(account.id).deliver_later
      create_intercom_user!(account)
      set_flash_message! :notice, :signed_up
      sign_in(:account, account)
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
    @minimum_password_length = Registration::SignUpForm::PASSWORD_LENGTH.min
  end
end
