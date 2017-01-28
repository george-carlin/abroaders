module AdminArea
  module Card
    module Operations
      class New < Trailblazer::Operation
        step :setup_person!
        # pass the 'person' option into New
        step Nested(::Card::Operations::New, input: ->(_, person:, **) { { person: person } })

        # This isn't pretty... also, it's display logic, so not sure it belongs
        # in here. FIXME
        def self.product_options
          ::CardProduct.all.map do |product|
            [AdminArea::CardProduct::Cell::Identifier.(product).(), product.id]
          end.sort_by { |p| p[0] }
        end

        private

        def setup_person!(opts, params:, **)
          opts['person'] = ::Person.find(params[:person_id])
        end

        def setup_model!(opts, person:, **)
          opts['model'] = ::Card.new(person: person)
        end
      end
    end
  end
end
