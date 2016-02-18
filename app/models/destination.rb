class Destination < ApplicationRecord
  self.inheritance_column = :_no_sti

  # From the `acts_as_tree` gem. Like adding `belongs_to :parent`, but with
  # some bells and whistles:
  acts_as_tree counter_cache: true

  # Attributes

  IATA_CODE_REGEX = /\A[A-Z]{3}\z/i

  delegate :name, to: :parent, prefix: true, allow_nil: true

  TYPES = %w[airport city state country region]
  enum type: TYPES

  # Add .airports, .cities etc as aliases for .airport, .country
  class << self
    TYPES.each { |type| alias_method type.pluralize, type }
  end

  # Assocations

  def region
    root.region? ? root : nil
  end

  # Validations

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true
  validates :parent, presence: { unless: :region? }

end
