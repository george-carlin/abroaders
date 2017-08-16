module Card::Cell
  class Survey < Abroaders::Cell::Base
    include NameHelper

    option :form

    def title
      'Add Cards'
    end

    alias person model

    private

    def sections
      cell(BankSection, collection: CardProduct.survey.group_by(&:bank).to_a)
    end

    # model: [bank, [array_of_card_products]]
    class BankSection < Abroaders::Cell::Base
      include Escaped

      private

      delegate :id, to: :bank

      def bank
        model[0]
      end

      def products_by_bp
        cell(BpSection, bank: bank, collection: products.group_by(&:bp))
      end

      def products
        model[1]
      end

      def name
        escape!(bank.name)
      end
    end

    # model: [ 'business'|'personal', [array_of_card_products] ]
    class BpSection < Abroaders::Cell::Base
      option :bank

      private

      def bank_id
        bank.id
      end

      def bp
        model[0]
      end

      def products
        cell(CardProduct::Cell::Survey::Product, collection: model[1])
      end
    end
  end
end
