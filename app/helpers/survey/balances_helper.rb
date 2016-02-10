module Survey
  module BalancesHelper

    def currency_balance_checkbox(currency)
      check_box_tag(
        "balances[][currency_id]",
        currency.id,
        false,
        class: "currency_balance_checkbox input-lg",
        id:    "currency_#{currency.id}_balance"
      )
    end

    def currency_balance_value_field(currency)
      text_field_tag(
        "balances[][value]",
        "",
        id:    "currency_#{currency.id}_balance_value",
        class: "currency_balance_value input-sm",
        placeholder: "What's your balance?",
        style: "display:none;",
        disabled: true
      )
    end

  end
end
