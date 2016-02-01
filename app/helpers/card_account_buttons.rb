module CardAccountButtons

  def card_account_apply_btn(card_account)
    raise "#{card_account} can't be applied for" unless card_account.applyable?
    link_to(
      "Apply",
      apply_card_account_path(card_account),
      id: "card_account_#{card_account.id}_apply_btn",
      class: "card-account-apply-btn btn btn-primary btn-sm"
    )
  end

  def card_account_applied_btn(card_account)
    raise "#{card_account} can't be applied for" unless card_account.applyable?
    link_to(
      "I have applied",
      "#",
      id: "card_account_#{card_account.id}_applied_btn",
      class: "card-account-have-applied-btn btn btn-info btn-sm",
      data: { card_account_id: card_account.id }
    )
  end

  def card_account_decline_btn(card_account)
    raise "#{card_account} can't be declined" unless card_account.declinable?
    button_to(
      "No Thanks",
      decline_card_account_path(card_account),
      id: "card_account_#{card_account.id}_decline_btn",
      class: "card-account-decline-btn btn btn-default btn-sm"
    )
  end

  def card_account_applied_back_btn(card_account)
    link_to(
      "Back",
      "#",
      id: "card_account_#{card_account.id}_applied_back_btn",
      class: "card-account-applied-back-btn",
      data: { card_account_id: card_account.id }
    )
  end

end
