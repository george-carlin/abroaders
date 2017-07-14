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
        property :created_at
        property :dead?
        property :killed_at
        property :last_reviewed_at
        property :link
        property :notes
        property :partner
        property :points_awarded
        property :updated_at
        property :value

        def title
          "Offer ##{id}"
        end

        private

        def active_recommendations?
          active_recommendations.any?
        end

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

        def created_at
          super.strftime('%D')
        end

        def days
          return '' if model.condition == 'on_approval'
          <<-HTML
            <dt>Days:</dt>
            <dd>#{model.days}</dd>
          HTML
        end

        def icons
          icons = []
          if dead?
            icons << fa_icon('times 2x', style: 'color: darkred;')
            if active_recommendations?
              icons << fa_icon('exclamation-triangle 2x', style: 'color: darkorange')
            end
          end
          icons.join('&nbsp;')
        end

        def killed_at
          super.strftime('%D')
        end

        def last_reviewed_at
          super ? super.strftime('%D') : 'never'
        end

        def link_to_dup_offer
          link_to(
            'Duplicate this offer',
            new_admin_card_product_offer_path(card_product, duplicate_id: id),
          )
        end

        def link_to_edit
          link_to 'Edit offer', edit_admin_offer_path(id)
        end

        def link_to_new_offer
          link_to(
            'New offer for product',
            new_admin_card_product_offer_path(card_product),
          )
        end

        def link_to_link
          link_to link, link, rel: 'nofollow'
        end

        def link_to_verify
          link_to(
            'Verify offer',
            verify_admin_offer_path(id),
            method: :patch,
            data: { confirm: 'Are you sure?' },
          )
        end

        def link_to_kill
          link_to(
            'Kill offer',
            kill_admin_offer_path(id),
            method: :patch,
            data: { confirm: 'Are you sure?' },
          )
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

        def updated_at
          super.strftime('%D')
        end

        def value
          super ? number_to_currency(super) : 'Unknown'
        end

        # model = array of recs
        class ActiveRecsTable < Abroaders::Cell::Base
          property :any?

          def show
            content = if any?
                        id = 'offer_active_recs_table'
                        cell(
                          table_cell,
                          model,
                          edit_redirection: :offer,
                          html_id: id,
                          with_person_column: true,
                        )
                      else
                        'No active card recommendations'
                      end
            "#{header}#{content}"
          end

          private

          def header
            text = 'Active recs'
            text << " (#{model.size})" if any?
            "<h4>#{text}</h4>"
          end

          def table_cell
            AdminArea::CardRecommendations::Cell::Table
          end
        end
      end
    end
  end
end
