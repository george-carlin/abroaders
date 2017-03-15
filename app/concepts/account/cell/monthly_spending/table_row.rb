class Account < Account.superclass
  module Cell
    module MonthlySpending
      class TableRow < Abroaders::Cell::Base
        property :couples?
        property :monthly_spending_usd

        def show
          content_tag :tr do
            content_tag(:td, label) << content_tag(:td, value)
          end
        end

        private

        def value
          number_to_currency(monthly_spending_usd)
        end

        def label
          "#{couples? ? 'Shared' : 'Personal'} spending:"
        end
      end
    end
  end
end
