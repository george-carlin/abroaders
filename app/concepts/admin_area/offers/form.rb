module AdminArea
  module Offers
    class Form < Reform::Form
      feature Coercion

      def self.model_name
        ::Offer.model_name
      end

      property :condition, type: Offer::Conditions, default: 'on_minimum_spend'
      property :partner, type: Offer::Partners
      property :points_awarded, type: Types::Form::Int
      property :spend, type: Types::Form::Int, default: 0
      property :cost, type: Types::Form::Int, default: 0
      property :days, type: Types::Form::Int, default: 90
      property :link, type: Types::StrippedString
      property :notes, type: Types::StrippedString

      with_options presence: true do
        validates :link
        validates :partner

        with_options numericality: {
          greater_than_or_equal_to: 0,
          less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
        } do
          validates :cost
          validates :days, unless: -> { condition == 'on_approval' }
          validates :points_awarded
          validates :spend, if: -> { condition == 'on_minimum_spend' }
        end
      end
    end
  end
end
