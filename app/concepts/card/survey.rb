require 'types'

# model: a Person
class Card::Survey < Reform::Form
  feature Coercion

  CardProductId = ::Dry::Types::Definition.new(Integer).constructor do |id|
    # raise an error if the card product doesn't exist:
    CardProduct.find(Types::Form::Int.(id)).id
  end

  collection :cards, populate_if_empty: Card do
    feature ActiveModel::FormBuilderMethods
    feature MultiParameterAttributes

    property :card_product_id, type: CardProductId
    property :opened_on, multi_params: true
    property :closed, type: Types::Form::Bool, virtual: true
    property :closed_on, multi_params: true
  end

  def validate(_params)
    super.tap do # don't set 'closed_on' if not closed:
      cards.each { |card| card.closed_on = nil unless card.closed }
    end
  end

  def save(*)
    super.tap do
      onboarder = Account::Onboarder.new(model.account)
      if model.owner?
        onboarder.add_owner_cards!
      else
        onboarder.add_companion_cards!
      end
    end
  end
end
