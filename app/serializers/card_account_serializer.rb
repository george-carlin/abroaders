class CardAccountSerializer < ApplicationSerializer
  attributes :id, :recommended_at, :applied_at, :opened_at, :earned_at, :closed_at,
             :decline_reason, :clicked_at, :declined_at, :denied_at, :nudged_at,
             :called_at, :redenied_at, :status

  has_one :card
end
