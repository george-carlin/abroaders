module AdminArea::Admins
  class New < Trailblazer::Operation
    extend Contract::DSL

    contract do
      property :email
      property :password

      validation do
        validates :email,
                  presence: true,
                  format: { with: Admin.email_regexp, allow_blank: true }
        validates :password,
                  presence: true,
                  length: { in: Admin.password_length, allow_blank: true }
      end
    end

    step Model(Admin, :new)
    step Contract::Build()
  end
end
