module CardAccountButtons

  def card_account_accepted_btn(card_account)
    raise "#{card_account} can't be accepted" unless card_account.acceptable?
    button_to(
      t("card_accounts.index.was_accepted"),
      open_card_account_path(card_account),
      id: "card_account_#{card_account.id}_accepted_btn",
      class: "btn btn-default btn-sm"
    )
  end

  def card_account_applied_btn(card_account)
    raise "#{card_account} can't be applied for" unless card_account.applyable?
    link_to(
      t("card_accounts.index.have_applied"),
      "#",
      id: "card_account_#{card_account.id}_applied_btn",
      class: "card-account-have-applied-btn btn btn-info btn-sm",
      data: { card_account_id: card_account.id }
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

  def card_account_apply_btn(card_account)
    raise "#{card_account} can't be applied for" unless card_account.applyable?
    link_to(
      "Apply",
      apply_card_account_path(card_account),
      id: "card_account_#{card_account.id}_apply_btn",
      class: "card-account-apply-btn btn btn-primary btn-sm"
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

  def card_account_deny_btn(card_account)
    button_to(
      t("card_accounts.index.was_denied"),
      deny_card_account_path(card_account),
      class: "card-account-deny-btn btn-default btn-sm"
    )
  end

  def card_account_pending_btn(card_account)
    link_to(
      t("card_accounts.index.still_waiting"),
      "#",
      id: "card_account_#{card_account.id}_pending_btn",
      class: "card-account-pending-btn btn btn-default btn-sm",
      data: { card_account_id: card_account.id }
    )
  end
end
