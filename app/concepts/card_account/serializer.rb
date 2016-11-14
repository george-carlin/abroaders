class CardAccount::Serializer < ApplicationSerializer
  attributes :id, :recommended_at, :applied_at, :opened_at, :earned_at, :closed_at,
             :decline_reason, :clicked_at, :declined_at, :denied_at, :nudged_at,
             :called_at, :redenied_at

  has_one :product

  # Hacky solution to prevent us from having to include card: :bank every time.
  # As the serializer is currently only being used in one place (to pass card
  # account attributes to the React component), I think we can get away with
  # this for now.
  [:to_json, :as_json].each do |method|
    define_method method do |*_args|
      # 'include' must be followed by an array. So this line would be invalid:
      # super(include: { product: :bank })
      # See https://stackoverflow.com/questions/27648904
      super(include: [{ product: :bank }])
    end
  end
end
