class RecommendationRequest < RecommendationRequest.superclass
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account] the currently logged-in account
    class Banner < Abroaders::Cell::Base
      def show
        wrapper do
          cell(Form, model)
        end
      end

      private

      def wrapper(&block)
        content_tag :div, class: 'hpanel' do
          content_tag :div, class: 'panel-body' do
            content_tag :div, class: 'row', &block
          end
        end
      end
    end
  end
end
