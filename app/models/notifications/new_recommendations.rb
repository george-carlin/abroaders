module Notifications
  class NewRecommendations < ::Notification
    belongs_to :record, class_name: "Person"

    def self.notify!(person)
      create!(account: person.account, record:  person)
    end
  end
end
