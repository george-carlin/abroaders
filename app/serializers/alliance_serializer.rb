class AllianceSerializer < ApplicationSerializer
  attributes :id, :name

  has_many :currencies

  always_include :currencies
end
