module Balance::Cell
  # model: the form builder for an individual balance form
  class Survey::BalanceFields < Abroaders::Cell::Base
    alias form_builder model
    alias f form_builder

    private

    def balance
      form.model
    end

    def currency
      balance.currency
    end

    def currency_id
      currency.id
    end

    def form
      form_builder.object
    end

    def visible?
      # note that this is the custom 'present' property of the Reform object,
      # not `present?` (the ActiveSupport method)
      form.present
    end
  end
end
