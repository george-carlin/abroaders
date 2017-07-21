module AdminArea::Admins
  class New < Trailblazer::Operation
    extend Contract::DSL

    PASSWORD_LENGTH = Registration::SignUpForm::PASSWORD_LENGTH.dup

    contract do
      property :email
      property :password

      validation do
        validates :email,
                  presence: true,
                  format: { with: EMAIL_REGEXP, allow_blank: true }
        validates :password,
                  presence: true,
                  length: { in: PASSWORD_LENGTH, allow_blank: true }
      end
    end

    step Model(Admin, :new)
    step Contract::Build()
  end
end
