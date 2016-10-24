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

    def tr_tag(&block)
      h.content_tag_for(
        :tr,
        self,
        "data-bp":       card.model.bp,
        "data-bank":     card.model.bank_id,
        "data-currency": card.model.currency_id,
        &block
      )
    end
  end
end
