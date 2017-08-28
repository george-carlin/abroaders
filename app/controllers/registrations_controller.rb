class RegistrationsController < ApplicationController
  prepend_before_action :require_no_authentication, only: [:new, :create]

  layout 'basic'
  include Abroaders::Controller::Onboarding
  include Auth::Controllers::SignInOut

  def new
    run Registration::New
    render cell(Registration::Cell::New, @model, form: @form)
  end

  def create
    run Registration::Create do
      flash[:notice] = I18n.t('devise.registrations.signed_up')
      sign_in(:account, @model)
      return redirect_to onboarding_survey_path
    end

    @form.clean_up_passwords
    render cell(Registration::Cell::New, @model, form: @form)
  end

  protected

  # Helper for use in before_actions where no authentication is required.
  #
  # Example:
  #   before_action :require_no_authentication, only: :new
  def require_no_authentication
    if warden.authenticated?(:account) && warden.user(:account)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to root_path
    end
  end
end
