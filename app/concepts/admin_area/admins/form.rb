module AdminArea::Admins
  class Form < Reform::Form
    property :email
    property :name

    validates :email,
              presence: true,
              format: { with: Admin.email_regexp, allow_blank: true }
    validates :name, presence: true
  end
end
