class CardProduct < ApplicationRecord
  class Serializer < ApplicationSerializer
    attributes :name, :network, :bp, :type

    has_one :bank
  end
end
