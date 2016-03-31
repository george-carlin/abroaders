module AdminArea
  module PassengersHelper

    def link_to_admin_passenger(passenger)
      link_to(passenger.full_name, admin_passenger_path(passenger))
    end

    def link_to_admin_passenger_recommend_card(passenger)
      link_to(
        new_admin_passenger_card_recommendation_path(passenger),
        class: "admin_passenger_recommend_card_link",
        title: "Recommend a card to this user"
      ) do
        raw '
          <i class="fa fa-credit-card-alt " style="margin-left: 5px"></i>
          <i class="fa fa-plus"></i>
        '
      end
    end

  end
end
