module AdminArea
  module Offers
    class Form < Reform::Form
      feature Coercion

      def self.model_name
        ::Offer.model_name
      end

      property :condition, type: Types::Strict::String.enum(*::Offer::CONDITIONS.keys)
      property :partner, type: Types::Strict::String.enum('', *::Offer::PARTNERS.keys)
      property :points_awarded, type: Types::Form::Int
      property :spend, type: Types::Form::Int
      property :cost, type: Types::Form::Int
      property :days, type: Types::Form::Int
      property :link, type: Types::StrippedString
      property :notes, type: Types::StrippedString

      with_options presence: true do
        # TODO validate it looks like a valid link:
        validates :link
        validates :partner,
                  inclusion: { in: ::Offer::PARTNERS.keys },
                  allow_blank: true

        with_options numericality: {
          greater_than_or_equal_to: 0,
          less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
        } do
          validates :cost
          validates :days, unless: :on_approval?
          validates :points_awarded
          validates :spend, if: :on_minimum_spend?
        end
      end

      def on_approval?
        condition == 'on_approval'
      end

      def on_minimum_spend?
        condition == 'on_minimum_spend'
      end
    end
  end
end
