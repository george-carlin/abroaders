class Balance::EditForm < Reform::Form
  feature Reform::Form::Dry

  def self.model_name
    Balance.model_name
  end

  property :value

  validation do
    required(:value).filled(:int?, gteq?: 0, lteq?: POSTGRESQL_MAX_INT_VALUE)
  end
end
