module AdminArea
  module Offer
    module Cell
      # model: an offer
      class Identifier < Trailblazer::Cell
        # A shorthand code that identifies the offer based on the points awarded,
        # minimum spend, and days. Note that this isn't necessarily unique per offer.
        def show
          parts = [points]
          case model.condition
          when 'on_minimum_spend'
            parts.push(spend)
            parts.push(model.days)
          when 'on_approval'
            parts.push('A')
          when 'on_first_purchase'
            parts.push('P')
          else raise 'this should never happen'
          end
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
