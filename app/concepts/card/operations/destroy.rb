class Card < Card.superclass
  module Operations
    class Destroy < Trailblazer::Operation
      success :setup_model!
      success :destroy_card!

      private

      def destroy_card!(opts, **)
        opts['model'].destroy!
      end

      def setup_model!(opts, account:, params:, **)
        opts['model'] = account.cards.find(params[:id])
      end
    end
  end
end
