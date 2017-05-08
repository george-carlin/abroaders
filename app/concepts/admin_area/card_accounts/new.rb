module AdminArea
  module CardAccounts
    class New < Trailblazer::Operation
      extend Contract::DSL
      contract NewForm

      step :setup_person!
      step :setup_model!
      step Contract::Build()

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
