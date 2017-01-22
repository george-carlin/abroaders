module AdminArea
  module Card
    module Operations
      class Create < Trailblazer::Operation
        # specify the full name of 'New' to avoid an ugly collision; see
        # https://github.com/trailblazer/trailblazer/issues/168
        step Nested(AdminArea::Card::Operations::New)
        step Contract::Validate(key: :card)
        step Contract::Persist()

        private

        def model!(params)
          Person.find(params[:person_id]).cards.new
        end
      end
    end
  end
end
