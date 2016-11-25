require_relative "../record_on_page"

module AdminArea
  class CardOnPage < RecordOnPage
    alias card model

    def has_status?(status)
      has_selector? ".card_status", text: status
    end

    %i[recommended seen clicked applied declined opened closed].each do |event|
      define_method :"has_#{event}_at_date?" do |date|
        has_selector? ".card_#{event}_at", text: date
      end

      define_method :"has_no_#{event}_at_date?" do
        has_selector? ".card_#{event}_at", text: "-"
      end
    end

    def click_pull_btn
      find("#card_#{card.id}_pull_btn").click
    end
  end
end
