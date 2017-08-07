class Admin < ApplicationRecord
  include Paperclip::Glue

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar
  # file validations are handled in the form object (using the file_validators
  # gem), but Paperclip requires us to explicitly state that there are no
  # validations in the model layer
  do_not_validate_attachment_file_type :avatar

  def full_name
    [first_name, last_name].join(' ')
  end
end
