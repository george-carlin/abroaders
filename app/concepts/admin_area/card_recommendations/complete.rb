module AdminArea
  module CardRecommendations
    # @!method self.call(params, options = {})
    #   @option params [Integer] person_id
    class Complete < Trailblazer::Operation
      success :setup_person
      success :setup_account

      step Wrap(Abroaders::Transaction) {
        success :create_rec_note
        success :send_notification
        success :resolve_recommendation_requests
      }

      private

      def setup_person(opts, params:, **)
        opts['person'] = ::Person.find(params.fetch(:person_id))
      end

      def setup_account(opts, person:, **)
        opts['account'] = person.account
      end

      def create_rec_note(opts, params:, account:, **)
        note = params[:recommendation_note]&.strip
        account.recommendation_notes.create!(content: note) if note.present?
        opts['model'] = account.recommendation_notes.last
      end

      def send_notification(person:, **)
        Notifications::NewRecommendations.notify!(person)
      end

      def resolve_recommendation_requests(account:, **)
        account.unresolved_recommendation_requests.each(&:resolve!)
      end
    end
  end
end
