class Card::Product::Serializer < ApplicationSerializer
  attributes :name, :network, :bp, :type

  has_one :bank
end
