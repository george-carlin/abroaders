class CompleteCardRecommendations < ApplicationService
  attr_reader :person

  def initialize(person)
    @person = person
  end

  def complete!
    transaction do
      @person.update_attributes!(last_recommendations_at: Time.now)
      notification = Notifications::NewRecommendations.notify!(@person)
      SendNotificationEmail.new(notification_id: notification)
    end
  end
end
