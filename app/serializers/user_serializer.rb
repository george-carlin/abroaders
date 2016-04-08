class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :pretty_created_at

  def pretty_created_at
    object.created_at.strftime("%c")
  end
end
