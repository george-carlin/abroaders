module AdminArea
  module CardAccounts
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract NewForm

      step :setup_person!
      step :setup_model!
      step Contract::Build()

      # This is display logic, it belongs in a cell, not an operation. REFACTORME
      def self.product_options
        CardProduct.all.map do |product|
          [CardProduct::Cell::FullName.(product, with_bank: true).(), product.id]
        end.sort_by { |p| p[0] }
      end

      private

      def setup_person!(opts, params:, **)
        opts['person'] = Person.find(params[:person_id])
      end

      def setup_model!(opts, person:, **)
        opts['model'] = Card.new(person: person)
      end
    end
  end
end
