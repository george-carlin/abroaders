module CardAccountsHelper

  def render_card_account(card_account, &block)
    render "card_accounts/card_account", card_account: card_account, &block
  end

  def apply_to_card_recommendation_btn(card_rec)
    link_to(
      "Apply",
      apply_card_account_path(card_rec),
      id: "card_recommendation_#{card_rec.id}_apply_btn",
      class: "card_recommendation_apply_btn btn btn-primary btn-sm",
      target: "_blank"
    )
  end

  def decline_card_recommendation_btn(card_rec)
    button_tag(
      "No Thanks",
      class: "card_recommendation_decline_btn btn btn-danger2 btn-sm",
      id:    "card_recommendation_#{card_rec.id}_decline_btn",
    )
  end


end
