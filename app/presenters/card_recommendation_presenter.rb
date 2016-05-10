class CardRecommendationPresenter < CardAccountPresenter

  def apply_btn
    h.link_to(
      "Apply",
      h.apply_card_recommendation_path(self),
      id: "card_recommendation_#{id}_apply_btn",
      class: "card_recommendation_apply_btn btn btn-primary btn-sm",
      target: "_blank"
    )
  end

  def decline_form(&block)
    h.form_tag(
      h.decline_card_recommendation_path(self),
      class: "decline_card_recommendation_form",
      style: "display:none;",
      &block
    )
  end

  def decline_reason_field_tag
    h.text_field_tag(
      "card_account[decline_reason]",
      "",
      class: "input-sm card_account_decline_reason",
      id: "card_account_#{id}_decline_reason",
      placeholder: "Why don't you want to apply for this card?",
    )
  end

  def decline_btn
    h.button_tag(
      "No Thanks",
      class: "card_recommendation_decline_btn btn btn-default btn-sm",
      id:    "card_recommendation_#{id}_decline_btn",
    )
  end

  def cancel_decline_btn
    h.button_tag(
      "Cancel",
      class: "card_recommendation_cancel_decline_btn btn btn-sm btn-default",
      id:    "card_recommendation_#{id}_cancel_decline_btn",
    )
  end

  def confirm_decline_btn
    h.button_tag(
      "Confirm",
      class: "card_recommendation_confirm_decline_btn btn btn-sm btn-primary",
      id: "card_recommendation_#{id}_confirm_decline_btn",
    )
  end

end
