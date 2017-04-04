class CardAccount < CardAccount.superclass
  module Cell
    class New < Abroaders::Cell::Base
      # The new card page is actually split into two 'pages'. When they first
      # go to add a new card, they'll see a page which lists the different card
      # products. Once they've selected a product they see a more
      # normal-looking form where they add the details (opened/closed dates)
      # etc regarding that product.
      #
      # This cell is the page which lists the products
      #
      # model = a collection of CardProducts.
      #
      # option: :banks = a collection of Banks
      class SelectProduct < Abroaders::Cell::Base
        alias collection model

        private

        def bank_select
          cell(BankSelect, options[:banks])
        end

        def banks
          collection.keys
        end

        # group products by bank, then by B/P
        def products_grouped_by_bank
          collection.group_by(&:bank).map do |bank, products|
            cell(ProductsGroupedByBank, bank, products: products)
          end.join
        end

        # model: a collection of Banks
        class BankSelect < Abroaders::Cell::Base
          HTML_ID = :new_card_bank_id

          def show
            select_tag :new_card_bank_id, options, prompt: 'What bank is the card from?'
          end

          private

          def options
            options_for_select(model.pluck(:name, :id))
          end
        end

        # model: a Bank
        # option: :products = the products for this bank
        class ProductsGroupedByBank < Abroaders::Cell::Base
          property :id

          def show
            content_tag :div, id: html_id, class: HTML_CLASS, style: 'display:none;' do
              cell(Product, collection: options[:products])
            end
          end

          private

          HTML_CLASS = 'bank_card_products'.freeze

          def html_id
            "bank_#{id}_card_products"
          end
        end

        # model: a CardProduct
        class Product < Abroaders::Cell::Base
          include ActionView::Helpers::RecordTagHelper

          private

          def link_to_select
            link_to(
              'Add this Card',
              new_product_card_account_path(model),
              class: 'btn btn-primary',
            )
          end

          def html_id
            dom_id(model)
          end
        end
      end
    end
  end
end
