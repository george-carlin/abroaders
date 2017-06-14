module AdminArea
  module Offers
    class Form < Reform::Form
      feature Coercion

      property :condition, type: Offer::Condition, default: 'on_minimum_spend'
      property :partner, type: Offer::Partner
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
          validates :days, if: :days_required?
          validates :points_awarded, if: -> { condition != 'no_bonus' }
          validates :spend, if: -> { condition == 'on_minimum_spend' }
        end
      end

      private

      def days_required?
        %w[on_minimum_spend on_first_purchase].include?(condition)
      end
    end
  end
end
