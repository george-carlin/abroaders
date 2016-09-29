module AdminArea
  class CurrencyPresenter < ApplicationPresenter
    alias_method :currency, :model

    def filter_label_tag
      h.label_tag(filter_css_id) { yield }
    end

    def filter_check_box_tag
      h.check_box_tag(
        filter_css_id,
        nil,
        true,
        class: filter_css_class,
        data: { key: :currency, value: id  }
      ) << raw("&nbsp;&nbsp#{name}")
    end

    private

    def filter_css_class
      "card_currency_filter"
    end

    def filter_css_id
      "#{filter_css_class}_#{id}"
    end

  end
end
