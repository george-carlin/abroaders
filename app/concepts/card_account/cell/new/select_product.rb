class CardAccount < CardAccount.superclass
  module Cell
    class New < Abroaders::Cell::Base
      # Top-level cell for card_accounts#new when no :product_id param is
      # given.
      #
      # See the docs for CardAccountsController#new for an explanation of how
      # the flow works and how this op is used.
      #
      # @!method self.call(products, options = {})
      #   @param result [Collection<Bank>]
      class SelectProduct < Abroaders::Cell::Base
        private

        def bank_select
          select_tag(
            :new_card_bank_id,
            options_for_select(model.pluck(:name, :id)),
            prompt: 'What bank is the card from?',
          )
        end

        def products_grouped_by_bank
          cell(Product::ForBank, collection: model)
        end

        # @!method self.call(product, options = {})
        #   @param product [CardProduct]
        class Product < Abroaders::Cell::Base
          property :id

          private

          def link_to_select
            link_to(
              'Add this Card',
              new_card_product_card_account_path(model),
              class: 'btn btn-primary',
            )
          end

          # @!method self.call(bank, options = {})
          class ForBank < Abroaders::Cell::Base
            property :id
            property :card_products

            def show
              content_tag :div, id: html_id, class: HTML_CLASS, style: 'display:none;' do
                cell(Product, collection: card_products).join('<hr>')
              end
            end

            HTML_CLASS = 'bank_card_products'.freeze

            def html_id
              "bank_#{id}_card_products"
            end
          end
        end
      end
    end
  end
end
