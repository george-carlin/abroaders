class RegistrationsController < Devise::RegistrationsController
  layout 'basic'
  include Onboarding

  def new
    run Registration::New
    set_minimum_password_length
  end

  def create
    run Registration::Create do
      AccountMailer.notify_admin_of_sign_up(@model.id).deliver_later
      create_intercom_user!(@model)
      set_flash_message! :notice, :signed_up
      sign_in(:account, @model)
      respond_with resource, location: onboarding_survey_path
      return
    end

    @form.clean_up_passwords
    set_minimum_password_length
    render "new"
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
