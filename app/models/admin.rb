class Admin < ApplicationRecord
  include Auth::Models::Authenticatable
  include Auth::Models::DatabaseAuthenticatable
  include Auth::Models::Rememberable
  include Auth::Models::Recoverable
  include Auth::Models::Registerable
  include Auth::Models::Trackable
  include Paperclip::Glue

  has_attached_file :avatar
  # file validations are handled in the form object (using the file_validators
  # gem), but Paperclip requires us to explicitly state that there are no
  # validations in the model layer
  do_not_validate_attachment_file_type :avatar

  def full_name
    [first_name, last_name].join(' ')
  end
end
