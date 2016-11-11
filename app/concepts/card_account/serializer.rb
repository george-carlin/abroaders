class CardAccount::Serializer < ApplicationSerializer
  attributes :id, :recommended_at, :applied_at, :opened_at, :earned_at, :closed_at,
             :decline_reason, :clicked_at, :declined_at, :denied_at, :nudged_at,
             :called_at, :redenied_at

  has_one :card

  # Hacky solution to prevent us from having to include card: :bank every time.
  # As the serializer is currently only being used in one place (to pass card
  # account attributes to the React component), I think we can get away with
  # this for now.
  [:to_json, :as_json].each do |method|
    define_method method do |*_args|
      super(include: { card: :bank })
    end
  end

  class CardSerializer < ApplicationSerializer
    attributes :name, :network, :bp, :type

    has_one :bank

    class BankSerializer < ApplicationSerializer
      attributes :name, :personal_phone, :business_phone
    end
  end
end
