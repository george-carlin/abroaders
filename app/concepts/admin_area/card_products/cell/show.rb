module AdminArea::CardProducts
  module Cell
    # model: CardProduct
    class Show < Abroaders::Cell::Base
      include Escaped

      property :name
      property :bp
      property :currency
      property :bank_name
      property :wallaby_id
      property :shown_on_survey
      property :created_at
      property :updated_at

      def title
        name
      end

      private

      def currency_name
        escape!(currency&.name)
      end
    end
  end
end
