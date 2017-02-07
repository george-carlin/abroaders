module AdminArea
  module Card
    module Cell
      # model: a Card
      class TableRow < Trailblazer::Cell
        include Escaped
        include FontAwesome::Rails::IconHelper

        property :id
        property :applied_at
        property :clicked_at
        property :closed_at
        property :decline_reason
        property :declined_at
        property :denied_at
        property :opened_at
        property :recommended_at
        property :seen_at
        property :status

        private

        def decline_reason
          if model.declined_at.nil?
            ''
          else
            link_to('#', 'data-toggle': 'tooltip', title: super) do
              fa_icon('question')
            end
          end
        end

        def link_to_edit
          link_to 'Edit', edit_admin_card_path(model)
        end

        def link_to_pull
          link_to(
            raw('&times;'),
            pull_admin_recommendation_path(model),
            data: {
              confirm: 'Really pull this recommendation?',
              method: :patch,
              remote: true,
            },
            id:    "card_#{id}_pull_btn",
            class: 'card_pull_btn',
          )
        end

        # If the card was opened/closed after being recommended by an admin,
        # we know the exact date it was opened closed. If they added the card
        # themselves (e.g. when onboarding), they only provide the month
        # and year, and we save the date as the 1st of thet month.  So if the
        # card was added as a recommendation, show the the full date, otherwise
        # show e.g.  "Jan 2016". If the date is blank, show '-'
        %i[closed_at opened_at].each do |date_attr|
          define_method date_attr do
            if model.recommended_at.nil? # if card is not a recommendation
              super()&.strftime('%b %Y') || '-' # Dec 2015
            else
              super()&.strftime('%D') || '-' # 12/01/2015
            end
          end
        end

        %i[
          recommended_at seen_at clicked_at applied_at denied_at declined_at
        ].each do |date_attr|
          define_method date_attr do
            super()&.strftime('%D') || '-' # 12/01/2015
          end
        end

        def tr_tag(&block)
          content_tag(
            :tr,
            id: dom_id(model),
            class: dom_class(model),
            'data-bp':       product.bp,
            'data-bank':     product.bank_id,
            'data-currency': product.currency_id,
            &block
          )
        end

        def product
          model.product
        end

        def product_identifier
          cell(AdminArea::CardProduct::Cell::Identifier, product)
        end

        def product_name
          product.name
        end

        def status
          Inflecto.humanize(super)
        end
      end
    end
  end
end
