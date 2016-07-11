class BalanceForm < ApplicationForm
  include Virtus.model

  attribute :id,     Integer
  attribute :value,  Integer
  attribute :person, Person

  delegate :id, to: :person, prefix: true

  def self.model_name
    Balance.model_name
  end

  # values of over around 2.1 billion will make PostgreSQL crash, but that's
  # way more miles than anyone will ever have:
  validates :value,
    numericality: {
      allow_nil: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 2_000_000_000,
    },
    presence: true
end
