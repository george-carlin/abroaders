module Registration
  class SignUpForm < Reform::Form
    feature Coercion

    property :email, type: Types::StrippedString
    property :password
    property :password_confirmation, virtual: true

    property :test, type: Types::Bool

    property :owner do
      property :first_name, type: Types::StrippedString
    end

    unnest :first_name, from: :owner

    EMAIL_REGEXP    = /\A[^@\s]+@[^@\s]+\z/
    PASSWORD_LENGTH = 8..72

    def clean_up_passwords
      self.password = self.password_confirmation = nil
    end

    validation do
      validates :email,
                presence: true,
                format: { with: EMAIL_REGEXP, allow_blank: true }

      validates :first_name,
                presence: true,
                length: { maximum: Person::NAME_MAX_LENGTH }
      validates :password,
                presence: true,
                length: { within: PASSWORD_LENGTH, allow_blank: true }

      validate do
        errors.add(:password_confirmation, "doesn't match password") if password != password_confirmation
      end

      validate(&Account::ValidateEmailUniqueness)
    end
  end
end
