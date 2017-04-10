module AdminArea
  module CardRecommendations
    # @!method self.call(params, options = {})
    #   @option params [Integer] person_id
    class Complete < Trailblazer::Operation
      success :setup_person
      success :setup_account
      success :complete_recs

      private

      def setup_person(opts, params:, **)
        opts['person'] = ::Person.find(params.fetch(:person_id))
      end

      def setup_account(opts, person:, **)
        opts['account'] = person.account
      end

      def complete_recs(opts, account:, params:, person:, **)
        ApplicationRecord.transaction do
          person.update_attributes!(last_recommendations_at: Time.zone.now)
          note = params[:recommendation_note]&.strip
          account.recommendation_notes.create!(content: note) if note.present?
          Notifications::NewRecommendations.notify!(person)
        end
        opts['model'] = account.recommendation_notes.last
      end
    end
  end
end
