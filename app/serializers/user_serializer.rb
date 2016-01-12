class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :full_name

  def full_name
    object.contact_info.try(:full_name)
  end
end
