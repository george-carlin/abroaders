class CardOfferSerializer < ActiveModel::Serializer
  attributes :id, :points_awarded, :spend, :cost, :days, :status
  has_one :card
end
