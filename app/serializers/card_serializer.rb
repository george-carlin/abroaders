class CardSerializer < ApplicationSerializer
  attributes :name, :network, :bp, :type, :identifier

  has_one :bank

  always_include :bank
end
