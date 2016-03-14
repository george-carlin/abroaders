class Form
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # A form object is never persisted
  def persisted?
    false
  end
end
