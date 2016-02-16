module BalancesHelper

  def currency_balance_checkbox(balance)
    check_box_tag(
      "balances[][currency_id]",
      balance.currency_id,
      balance.value.present?,
      class: "currency_balance_checkbox input-lg",
      id:    "currency_#{balance.currency_id}_balance"
    )
  end

  def currency_balance_value_field(balance)
    currency = balance.currency
    visible  = balance.value.present?
    text_field_tag(
      "balances[][value]",
      balance.value,
      id:    "currency_#{currency.id}_balance_value",
      class: "currency_balance_value input-sm",
      placeholder: "What's your balance?",
      style: visible ? "" : "display:none;",
      disabled: !visible
    )
  end

end
