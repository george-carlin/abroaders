module AdminArea
  module CardRecommendations
    module Cell
      module ProductsTable
        # REFACTOR this cell belongs in the AdminArea::People::Cell::Show
        # namespace, not here
        class Row < Abroaders::Cell::Base
          property :id
          property :bank_name
          property :bank_id
          property :bp
          property :currency_name
          property :currency_id
          property :name

          private

          def product_identifier
            link_to(
              "Card #{CardProducts::Cell::Identifier.(model)}",
              admin_card_product_offers_path(model),
            )
          end

          def tr_tag(&block)
            content_tag(
              :tr,
              id: "admin_recommend_card_product_#{id}",
              class: 'admin_recommend_card_product',
              data: { bp: bp, bank: bank_id },
              &block
            )
          end
        end
      end
    end
  end
end
