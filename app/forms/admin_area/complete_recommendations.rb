module AdminArea
  class CompleteRecommendations < ApplicationForm
    include Virtus.model

    attribute :person, Person
    attribute :note,   String

    delegate :account, to: :person

    def persist!
      note.strip! if note.present?
      transaction do
        person.update_attributes!(last_recommendations_at: Time.zone.now)
        account.recommendation_notes.create!(content: note) if note.present?
      end
    end
  end
end
