class CardOfferSerializer < ActiveModel::Serializer
  attributes :id, :points_awarded, :spend, :cost, :days, :live
  has_one :card
end
