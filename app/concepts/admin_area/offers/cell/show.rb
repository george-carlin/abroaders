require 'inflecto'

module AdminArea
  module Offers
    module Cell
      # @!method self.call(offer)
      #   @param offer [Offer]
      class Show < Abroaders::Cell::Base
        property :id
        property :active_recommendations
        property :bank_name
        property :card_product
        property :condition
        property :cost
        property :link
        property :notes
        property :partner
        property :points_awarded
        property :value

        def title
          "Offer ##{id}"
        end

        private

        def active_recs_table
          cell(ActiveRecsTable, active_recommendations)
        end

        def alternatives_table
          cell(Offers::Cell::AlternativesTable::Section, model)
        end

        def card_product_summary
          cell(CardProducts::Cell::Summary, card_product)
        end

        def cost
          number_to_currency(super)
        end

        def condition
          Inflecto.humanize(super)
        end

        def days
          return '' if model.condition == 'on_approval'
          <<-HTML
            <dt>Days:</dt>
            <dd>#{model.days}</dd>
          HTML
        end

        def link_to_edit
          link_to 'Edit offer', edit_admin_offer_path(id)
        end

        def link_to_link
          link_to link, link, rel: 'nofollow'
        end

        def partner_name
          cell(Partner::Cell::FullName, partner)
        end

        def points_awarded
          number_with_delimiter(super)
        end

        def spend
          return '' unless model.condition == 'on_minimum_spend'
          <<-HTML
            <dt>Spend:</dt>
            <dd>#{number_to_currency(model.spend)}</dd>
          HTML
        end

        def value
          super ? number_to_currency(super) : 'Unknown'
        end

        # model = array of recs
        class ActiveRecsTable < Abroaders::Cell::Base
          def show
            content = if model.any?
                        id = 'offer_active_recs_table'
                        cell(table_cell, model, html_id: id, with_person_column: true)
                      else
                        'No active card recommendations'
                      end
            "<h4>Active recs</h4>#{content}"
          end

          private

          def table_cell
            AdminArea::CardRecommendations::Cell::Table
          end
        end
      end
    end
  end
end
