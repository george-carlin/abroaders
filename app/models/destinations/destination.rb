class Destination < ApplicationRecord
  # From the `acts_as_tree` gem. Like adding `belongs_to :parent`, but with
  # some bells and whistles:
  acts_as_tree counter_cache: true

  # Attributes

  delegate :name, to: :parent, prefix: true, allow_nil: true

  # Note: in the production database we have Alaska and Hawaii as "countries"
  # even though they're not countries in real life. (The US is named "United
  # States (Continental 48)". This is to simplify the code in the travel plan
  # form, so we can just call Country.all and not have to worry
  # about including Alaska and Hawaii separately. In the future when the travel
  # plan form setup is more complicated, we may change them to regions.

  TYPES = %w[airport city state country region]

  TYPES.each do |type|
    scope type, -> { where(type: type.capitalize) }

    define_method "#{type}?" do
      self.type == type.capitalize
    end
  end

  class << self
    # Add both singular name (e.g. .airport) and plural (airports) as scopes:
    TYPES.each do |type|
      alias_method type.pluralize, type
    end
  end

  # Assocations

  # If this is a Region, return self. Else return the Region at the top
  # of the hierarchy.
  def region
    root.region? ? root : nil
  end

  # Validations

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :type }
  validates :type, presence: true

end
