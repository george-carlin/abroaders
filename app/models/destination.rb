class Destination < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  enum type: [:airport, :city, :state, :country, :region]

  # Validations

  validates :name, presence: true
  validates :code, presence: true
  validates :type, presence: true, uniqueness: { scope: :parent }
  validates :parent, presence: { unless: :region? }
end
