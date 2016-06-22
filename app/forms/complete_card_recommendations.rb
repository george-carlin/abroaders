class CompleteCardRecommendations < ApplicationForm
  include Virtus.model

  attribute :person, Person
  attribute :note,   String

  delegate :account, to: :person

  def persist!
    transaction do
      person.update_attributes!(last_recommendations_at: Time.now)
      Notifications::NewRecommendations.notify!(person)
      if note.present?
        account.recommendation_notes.create!(content: note.strip)
      end
    end
  end

end
