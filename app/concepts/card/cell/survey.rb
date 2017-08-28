module Card::Cell
  # model: Person
  class Survey < Abroaders::Cell::Base
    include Escaped

    property :first_name
    property :partner?

    option :form

    def title
      partner? ? "#{first_name}'s Cards" : 'Cards'
    end

    alias person model

    private

    def confirm_no
      cell(ConfirmNo, model)
    end

    def initial
      cell(Initial, model)
    end

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
        cell(Product, collection: model[1])
      end
    end

    # model: Person
    class ConfirmNo < Abroaders::Cell::Base
      include Escaped

      property :first_name
      property :partner?

      def you_have
        partner? ? "#{first_name} has" : 'You have'
      end
    end

    # model: Person
    class Initial < Abroaders::Cell::Base
      include Escaped

      property :first_name
      property :partner?

      private

      def do_you
        partner? ? "Does #{first_name}" : 'Do you'
      end
    end
  end
end
