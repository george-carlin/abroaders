FactoryGirl.define do
  factory(
    :notification,
    aliases: [:unseen_notification],
    class: Notifications::NewRecommendations
  ) do
    record_id 1
    seen false

    trait :seen do
      seen true
    end

    trait :unseen do
      seen false
    end

    factory :seen_notification, traits: [:seen]
  end
end
