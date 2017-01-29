module AdminArea
  class CardPresenter < ::Card::Presenter
    def link_to_pull
      h.link_to(
        raw("&times;"),
        h.pull_admin_recommendation_path(self),
        data: {
          confirm: "Really pull this recommendation?",
          method: :patch,
          remote: true,
        },
        id:    "card_#{id}_pull_btn",
        class: "card_pull_btn",
      )
    end

    def tr_tag(&block)
      h.content_tag_for(
        :tr,
        self,
        "data-bp":       model.product.bp,
        "data-bank":     model.product.bank_id,
        "data-currency": model.product.currency_id,
        &block
      )
    end
  end
end
