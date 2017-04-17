module AdminArea
  module CardRecommendations
    # Mark a user's card recommendations as complete. This action is necessary
    # because we only want to send one notification etc. per rec 'batch', but
    # an admin will often recommend more than one card at the same time, so we
    # can't attach the notification etc. to the card rec creation op.
    #
    # The admin should only trigger this action *once* per account, not per
    # person (remember that the account might have two people who needs recs.)
    # It's not the perfect setup but it will do for now.
    #
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
        opts['person'] = Person.find(params.fetch(:person_id))
      end

      def setup_account(opts, person:, **)
        opts['account'] = person.account
      end

      def create_rec_note(opts, params:, account:, **)
        note = params[:recommendation_note]&.strip
        account.recommendation_notes.create!(content: note) if note.present?
        opts['recommendation_note'] = account.recommendation_notes.last
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
