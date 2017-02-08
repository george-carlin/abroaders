module AdminArea
  module CardRecommendation
    module Cell
      module ProductsTable
        class Row < Trailblazer::Cell
          include ActionView::Helpers::RecordTagHelper

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
            cell(AdminArea::CardProduct::Cell::Identifier, model)
          end

          def tr_tag(&block)
            content_tag(
              :tr,
              id: dom_id(model, :admin_recommend),
              class: dom_class(model, :admin_recommend),
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
