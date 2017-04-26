module Abroaders
  module Cell
    class RecommendationAlert < Abroaders::Cell::Base
      # @param account [Account] the currently logged-in account
      def initialize(model, options = {})
        raise 'model must be an Account' unless model.is_a?(Account)
        raise ArgumentError, "can't render #{self.class}" unless self.class.show?(model)
        super
      end

      include ::Cell::Builder

      builds do |account|
        [
          CardRecommendation::Cell::UnresolvedAlert,
          RecommendationRequest::Cell::UnresolvedAlert,
          RecommendationRequest::Cell::CallToAction,
        ].detect { |cell| cell.show?(account) } || Nothing
      end

      BTN_CLASSES = 'btn btn-success'.freeze # TODO lg?

      property :couples?

      def show
        return '' unless self.class.show?(model)
        <<-HTML
          <div class="alert alert-info">
            #{header}

            <p style="font-size: 14px;">
              #{main_text}
            </p>

            #{actions}
          </div>
        HTML
      end

      def self.show?(_model)
        raise NotImplementedError, 'subclasses must implement .show?'
      end

      private

      def actions
        ''
      end

      def names_for(people)
        owner_first = people.sort_by(&:type).reverse
        escape(owner_first.map(&:first_name).join(' and '))
      end

      class Nothing < Abroaders::Cell::Base
        def show
          ''
        end
      end
    end
  end
end
