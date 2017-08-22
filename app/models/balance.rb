class Balance < ApplicationRecord
  # Attributes

  delegate :name, to: :currency, prefix: true

  # Associations

  belongs_to :person
  belongs_to :currency
end
