class CardSerializer < ApplicationSerializer
  attributes :id, :name, :network, :bp, :type, :identifier

  has_one :bank
  has_one :currency

  always_include :bank
  always_include :currency
end
