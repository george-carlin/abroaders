class Bank < ApplicationRecord
  has_many :card_products

  def serializer_class
    Bank::Serializer
  end
end
