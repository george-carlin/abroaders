module AdminArea
  module CardRecommendations
    module Cell
      # @!method self.call(recommendations)
      #   @param recommendations [Collection<CardRecommendation>]
      #   @return [String] a <table> tag
      class Table < Abroaders::Cell::Base
        private

        def table_rows
          cell(Row, collection: model)
        end

        def table_tag(&block)
          content_tag(
            :table,
            class: 'table table-striped tablesorter',
            id: 'admin_person_card_recommendations_table',
            &block
          )
        end

        # @!method self.call(recommendation)
        #   @param recommendation [CardRecommendation]
        class Row < Abroaders::Cell::Base
          include Escaped

          property :id
          property :applied_on
          property :clicked_at
          property :decline_reason
          property :declined?
          property :declined_at
          property :product
          property :recommended_at
          property :seen_at
          property :status

          delegate :name, to: :product, prefix: true

          private

          %i[
            recommended_at seen_at clicked_at denied_at declined_at applied_on
          ].each do |date_attr|
            define_method date_attr do
              super()&.strftime('%D') || '-' # 12/01/2015
            end
          end

          # If the card was opened/closed after being recommended by an admin,
          # we know the exact date it was opened closed. If they added the card
          # themselves (e.g. when onboarding), they only provide the month
          # and year, and we save the date as the 1st of thet month.  So if the
          # card was added as a recommendation, show the the full date, otherwise
          # show e.g.  "Jan 2016". If the date is blank, show '-'
          #
          # TODO rethink how we know whether a card was added in the survey
          %i[closed_on opened_on].each do |date_attr|
            define_method date_attr do
              # if model.recommended_at.nil? # if card is not a recommendation
              # super()&.strftime('%b %Y') || '-' # Dec 2015
              # else
              super()&.strftime('%D') || '-' # 12/01/2015
              # end
            end
          end

          def tr_tag(&block)
            content_tag(
              :tr,
              id: "card_recommendation_#{id}",
              class: 'card_recommendation',
              'data-bp':       product.bp,
              'data-bank':     product.bank_id,
              'data-currency': product.currency_id,
              &block
            )
          end

          def product_identifier
            cell(CardProducts::Cell::Identifier, product)
          end

          def status
            Inflecto.humanize(super)
          end

          def decline_reason_tooltip
            return '' unless model.declined?
            link_to('#', 'data-toggle': 'tooltip', title: decline_reason) do
              fa_icon('question')
            end
          end

          def link_to_pull
            link_to(
              raw('&times;'),
              pull_admin_card_recommendation_path(model),
              data: {
                confirm: 'Really pull this recommendation?',
                method: :patch,
                remote: true,
              },
              id:    "card_recommendation_#{id}_pull_btn",
              class: 'card_recommendation_pull_btn',
            )
          end
        end
      end
    end
  end
end
