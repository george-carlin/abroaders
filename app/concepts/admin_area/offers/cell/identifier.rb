module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer, options = {})
      #   @option options [Boolean] with_partner (false) if true, adds the
      #     two-letter code for the offer's affiliate partner to the end of
      #     the identifier
      class Identifier < Abroaders::Cell::Base
        option :with_partner, default: false

        # A shorthand code that identifies the offer based on the points awarded,
        # minimum spend, and days. Note that this isn't necessarily unique per offer.
        def show
          parts = []
          case model.condition
          when 'on_minimum_spend'
            parts.push(points)
            parts.push(spend)
            parts.push(model.days)
          when 'on_approval'
            parts.push(points)
            parts.push('A')
          when 'on_first_purchase'
            parts.push(points)
            parts.push('P')
          when 'no_bonus'
            parts.push('NB')
          else raise 'this should never happen'
          end
          parts << cell(Partner::Cell::ShortName, model.partner) if with_partner
          parts.join('/')
        end

        private

        def points
          # Show points and spend as multiples of 1000, but don't print the decimal
          # point if it's an exact multiple:
          (model.points_awarded / 1000.0).to_s.sub(/\.0+\z/, '')
        end

        def spend
          (model.spend / 1000.0).to_s.sub(/\.0+\z/, '')
        end
      end
    end
  end
end
