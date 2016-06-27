require_relative "../model_on_page"

module AdminArea
  class CardAccountOnPage < ModelOnPage
    alias_method :card_account, :model

    def has_status?(status)
      has_selector? ".card_account_status", text: status
    end

    %i[recommended clicked applied declined].each do |event|
      define_method :"has_#{event}_at_date?" do |date|
        has_selector? ".card_account_#{event}_at", text: date
      end

      define_method :"has_no_#{event}_at_date?" do
        has_selector? ".card_account_#{event}_at", text: "-"
      end
    end

  end
end
