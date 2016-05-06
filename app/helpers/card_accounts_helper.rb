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

  def decline_card_recommendation_form(card_rec)
    form_tag(
      decline_card_account_path(card_rec),
      class: "decline_card_recommendation_form",
      style: "display:none;"
    ) do
      (content_tag :div do
        text_field_tag(
          "card_account[decline_reason]",
          "",
          class: "input-sm card_account_decline_reason",
          id: "card_account_#{card_rec.id}_decline_reason",
          placeholder: "Why don't you want to apply for this card?",
        )
      end) +

      button_tag(
        :Cancel,
        class: "card_recommendation_cancel_decline_btn btn btn-sm btn-default",
        id:    "card_recommendation_#{card_rec.id}_cancel_decline_btn",
      ) +

      button_tag(
        :Confirm,
        class: "card_recommendation_confirm_decline_btn btn btn-sm btn-primary",
        id: "card_recommendation_#{card_rec.id}_confirm_decline_btn",
      ) +

      content_tag(
        :span,
        "Please include a message",
        class: "decline_card_recommendation_error_message",
        style: "display:none;",
      )
    end
  end

end
