module AdminArea
  class CardAccountPresenter < ::CardAccountPresenter

    def link_to_pull
      h.link_to(
        raw("&times;"),
        h.pull_admin_card_recommendation_path(self),
        data: {
          confirm: "Really pull this recommendation?",
          method: :patch,
          remote: true,
        },
        id:    "card_account_#{id}_pull_btn",
        class: "card_account_pull_btn",
      )
    end

  end
end
