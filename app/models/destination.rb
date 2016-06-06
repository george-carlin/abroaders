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

  # Note: in the production database we have Alaska and Hawaii as "countries"
  # even though they're not countries in real life. (The US is named "United
  # States (Continental 48)". This is to simplify the code in the travel plan
  # form, so we can just call Destination.country.all and not have to worry
  # about including Alaska and Hawaii separately. In the future when the travel
  # plan form setup is more complicated, we may change them to regions.

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

  validate :parent_is_correct_type

  private

  def parent_is_correct_type
    if parent&.type.present? && type?
      unless TYPES[(TYPES.index(type)+1)..-1].include?(parent.type)
        errors.add(:parent, "type is invalid")
      end
    end
  end

end
