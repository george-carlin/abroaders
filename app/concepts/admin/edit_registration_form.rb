require 'constants'
require 'types'

# FIXME this class contains massive duplication of code from Registration::EditForm:
class Admin::EditRegistrationForm < Reform::Form
  feature Reform::Form::Coercion

  property :password, virtual: true
  property :password_confirmation, virtual: true
  property :current_password, virtual: true

  PASSWORD_LENGTH = Registration::SignUpForm::PASSWORD_LENGTH.dup

  validation do
    validates(
      :password,
      length: { within: PASSWORD_LENGTH, allow_blank: true },
    )

    # http://trailblazer.to/gems/reform/validation.html#confirm-validation
    validate :confirm_password

    validate :require_current_password_to_change_password
  end

  private

  def confirm_password
    if password.present? && (password != password_confirmation)
      errors.add(:password_confirmation, "Doesn't match password")
    end
  end

  def require_current_password_to_change_password
    # The current password is only required if they're updating their password
    return unless password.present?
    return if model.valid_password?(current_password)
    errors.add(:current_password, current_password.blank? ? :blank : :invalid)
  end

  # Override the method that Reform calls internall when you call Form#save so
  # that their current password is required - but only if they're changing
  # their password.
  def save_model
    if password.present?
      # The attributes will already be set on `model`, but not persisted.
      # Annoyingly, devise doesn't provide a 'save_with_password' method, only
      # 'update_with_password', which requires *all* the updated attrs to be
      # passed as args. This is the least bad solution I could come up with to
      # get those attrs:
      attrs = schema.keys.each_with_object({}) { |k, h| h[k.to_sym] = self.send(k) }
      model.update_with_password(attrs)
    else
      model.save!
    end
  end
end
