module AdminArea
  module CardRecommendations
    module Cell
      module ProductsTable
        class Row < Abroaders::Cell::Base
          property :id
          property :bank
          property :bank_id
          property :bp
          property :currency
          property :currency_id
          property :name

          private

          def bank_name
            bank.name
          end

          def currency_name
            currency.name
          end

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
              data: {
                bp:       bp,
                bank:     bank_id,
                currency: currency_id,
              },
              &block
            )
          end
        end
      end
    end
  end
end
