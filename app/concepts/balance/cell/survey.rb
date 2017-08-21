module Balance::Cell
  # model: a Person
  class Survey < Abroaders::Cell::Base
    include Escaped
    include NameHelper

    property :first_name
    property :partner?

    option :form

    def title
      if partner?
        "#{first_name}'s Points and Miles"
      else
        'Points and Miles'
      end
    end

    private

    def currency_balance_value_field(balance)
      currency = balance.currency
      visible  = !balance.value.nil?
      text_field_tag(
        "balances[][value]",
        balance.value,
        id:    "currency_#{currency.id}_balance_value",
        class: "currency_balance_value input-sm",
        placeholder: "What's your balance?",
        style: visible ? "" : "display:none;",
        disabled: !visible,
      )
    end

    def currency_balance_checkbox(balance)
      check_box_tag(
        "balances[][currency_id]",
        balance.currency_id,
        !balance.value.nil?,
        class: "currency_balance_checkbox input-lg",
        id:    "currency_#{balance.currency_id}_balance",
      )
    end
  end
end
