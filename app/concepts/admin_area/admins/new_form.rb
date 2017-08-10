module AdminArea::Admins
  class NewForm < Form
    property :password
    validates :password,
              presence: true,
              length: { in: Admin.password_length, allow_blank: true }
  end
end
