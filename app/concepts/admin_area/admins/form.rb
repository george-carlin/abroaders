module AdminArea::Admins
  class Form < Reform::Form
    property :email
    property :name
    property :avatar

    validates :email,
              presence: true,
              format: { with: Admin.email_regexp, allow_blank: true }
    validates :name, presence: true
    validates :avatar,
              presence: true,
              file_content_type: { allow: %w[image/jpeg image/jpg image/png] },
              file_size: { less_than: 2.megabytes }
  end
end
