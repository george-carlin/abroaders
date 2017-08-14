require 'constants'

module AdminArea::Admins
  class Form < Reform::Form
    feature Coercion

    property :email, type: Types::StrippedString
    property :first_name, type: Types::StrippedString
    property :last_name, type: Types::StrippedString
    property :avatar
    property :job_title, type: Types::StrippedString
    property :bio, type: Types::StrippedString

    validates :email,
              presence: true,
              format: { with: EMAIL_REGEXP, allow_blank: true }
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :avatar,
              presence: true,
              file_content_type: { allow: %w[image/jpeg image/jpg image/png] },
              file_size: { less_than: 2.megabytes }
  end
end
