# An upcoming flight or series of flights that the user wants to take.  Can be
# 'one_way', 'round_trip', or 'multi' (multi-leg) - these names are
# self-explanatory.  However, note that there's no way to actually create a
# 'multi' travel plan at present through the normal web-based flow of the app.
# We've postponed this feature as it's low-priority and MUCH more complicated
# than one-way/round-trip in terms of interface design.
#
# A TravelPlan has_many Flights, and each Flight has a 'from' destination and a
# 'to' destination. This is where the information about the user's desired
# destinations is stored (i.e. it's not stored directly on the travel plan.)
# Note that both one-way and round-trip travel plans only have one associated
# flight (i.e. return flights don't have 2 flights; this would just be
# redundant data since the second flight would always just be the first flight
# with 'from' and 'to' swapped). Since there aren't any 'multi' TravelPlans in
# the current app, there are also by definition no TravelPlans with more than
# one associated Flight.
class TravelPlan < ApplicationRecord
  # By default, if Rails sees a column called 'type' it assumes we want to use
  # single-table inheritiance in this model. Override 'inheritance_column' to
  # tell Rails that this isn't the case:
  self.inheritance_column = :_no_sti

  # Attributes

  Type = Types::Strict::String.default('round_trip').enum('one_way', 'round_trip')
  enum type: Type.values

  attribute_type :type, Type

  def one_way?
    type == 'one_way'
  end

  def round_trip?
    type == 'round_trip'
  end

  MAX_FLIGHTS    = 20
  MAX_PASSENGERS = 20

  def editable?
    flight = flights[0]
    ![flight.to.class, flight.from.class].include?(Country)
  end

  # Associations

  belongs_to :account
  has_many :flights, -> { order("position ASC") }

  accepts_nested_attributes_for :flights

  # Scopes

  scope :includes_destinations, -> do
    includes(flights: { from: { parent: :parent }, to: { parent: :parent } })
  end
end
