class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :created_at, :pretty_created_at

  def full_name
    # If no full name is provided, return an empty string instead of nil so we
    # don't have to worry about type-checking when consuming the API
    object.survey.try(:full_name) || ""
  end

  def pretty_created_at
    object.created_at.strftime("%c")
  end
end
