# A loyalty currency such as miles or points which a user can spend on flights
# (and other rewards)
#
# An specific user's balance in a specific currency (if they have one) is
# stored in the `balances` table.
#
# Attributes:
# - name:
#     the currency's name. This will be seen by users; i.e. it's not just for
#     our internal use
#
# - award_wallet_id:
#      the name that AwardWallet use for this currency. At the the time of
#      writing we haven't implemented any integration with AwardWallet yet, so
#      data in this column is just being stored for future or use
#
# - shown_on_survey:
#       whether or not the user is asked about this currency (and asked to tell
#       us their balance in this currency if they have one) on the 'balances'
#       page of the onboarding survey
#
# - alliance_name
#       which Alliance the currency belongs to, if any. See
#       app/models/alliance.rb
#
class Currency < ApplicationRecord
  self.inheritance_column = :_no_sti

  # Attributes

  TYPES = %w[airline bank hotel].freeze

  # Validations

  # Associations

  def alliance
    Alliance.new(name: alliance_name)
  end

  # Scopes

  scope :alphabetical, -> { order(name: :asc) }
  scope :survey, -> { where(shown_on_survey: true) }
  # currencies that the admin can filter by on people/show
  scope :filterable, -> { where(type: "airline") }
end
