class Destination < ApplicationRecord
  self.inheritance_column = :_no_sti

  acts_as_tree

  # Attributes

  delegate :name, to: :parent, prefix: true, allow_nil: true

  TYPES = %w[airport city state country region]
  enum type: TYPES

  # Add .airports, .cities etc as aliases for .airport, .country
  class << self
    TYPES.each { |type| alias_method type.pluralize, type }
  end

  # Validations

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true
  # TODO uncomment this once we've added regions:
  # validates :parent, presence: { unless: :region? }
end
