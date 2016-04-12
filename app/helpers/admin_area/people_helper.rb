module AdminArea
  module PeopleHelper

    def admin_link_to_recommend_card(person)
      link_to(
        "Recommend a card",
        new_admin_person_card_recommendation_path(person)
      )
    end

  end
end
