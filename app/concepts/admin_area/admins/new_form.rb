module AdminArea::Admins
  class NewForm < Form
    PASSWORD_LENGTH = Registration::SignUpForm::PASSWORD_LENGTH.dup

    property :password
    validates :password,
              presence: true,
              length: { in: PASSWORD_LENGTH, allow_blank: true }
  end
end
