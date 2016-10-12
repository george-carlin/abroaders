require_relative "../record_on_page"

module AdminArea
  class CardAccountOnPage < RecordOnPage
    alias card_account model

    def has_status?(status)
      has_selector? ".card_account_status", text: status
    end

    %i[recommended seen clicked applied declined opened closed].each do |event|
      define_method :"has_#{event}_at_date?" do |date|
        has_selector? ".card_account_#{event}_at", text: date
      end

      define_method :"has_no_#{event}_at_date?" do
        has_selector? ".card_account_#{event}_at", text: "-"
      end
    end

    def click_pull_btn
      find("#card_account_#{card_account.id}_pull_btn").click
    end
  end
end
