module AdminArea
  module CardRecommendations
    module Operation
      class Complete < Trailblazer::Operation
        step :process

        private

        def process(opts, params:, **)
          person  = ::Person.find(params[:person_id])
          account = person.account

          ApplicationRecord.transaction do
            person.update_attributes!(last_recommendations_at: Time.zone.now)
            note = params[:recommendation_note]&.strip
            account.recommendation_notes.create!(content: note) if note.present?
            Notifications::NewRecommendations.notify!(person)
          end
          opts['person'] = person
          opts['model']  = account.recommendation_notes.last
          true
        end
      end
    end
  end
end
