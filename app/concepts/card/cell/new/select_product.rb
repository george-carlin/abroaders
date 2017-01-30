class Card < ApplicationRecord
  module Cell
    class New < Trailblazer::Cell
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
      class SelectProduct < Trailblazer::Cell
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
        class BankSelect < Trailblazer::Cell
          include ActionView::Helpers::FormOptionsHelper
          include BootstrapOverrides::Overrides

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
        class ProductsGroupedByBank < Trailblazer::Cell
          property :id

          def show
            content_tag :div, id: html_id, class: HTML_CLASS, style: 'display:none;' do
              cell(Card::Cell::New::SelectProduct::Product, collection: options[:products])
            end
          end

          private

          HTML_CLASS = 'bank_card_products'.freeze

          def html_id
            "bank_#{id}_card_products"
          end
        end

        class Product < Trailblazer::Cell
          include ActionView::Helpers::RecordTagHelper

          property :id

          private

          def link_to_select
            link_to(
              'Add this Card',
              new_card_path(product_id: id),
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
