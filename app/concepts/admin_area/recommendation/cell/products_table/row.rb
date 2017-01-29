module AdminArea
  module Recommendation
    module Cell
      module ProductsTable
        class Row < ::CardProduct::Cell
          include ActionView::Helpers::RecordTagHelper

          private

          def tr_tag(&block)
            content_tag(
              :tr,
              id: html_id,
              class: html_classes,
              data: data,
              &block
            )
          end

          def data
            {
              bp:       model.bp,
              bank:     model.bank_id,
              currency: model.currency_id,
            }
          end

          def html_id
            dom_id(model, :admin_recommend)
          end

          def html_classes
            dom_class(model, :admin_recommend)
          end
        end
      end
    end
  end
end
