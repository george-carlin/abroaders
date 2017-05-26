class CardAccount < CardAccount.superclass
  module Query
    class AnnualFeeDue
      def self.call
        today = Date.today
        current_year = today.year
        current_month = today.month

        Card.accounts.unclosed.where(
          %[date_part('month', "cards"."opened_on") = #{current_month}
          AND date_part('year', "cards"."opened_on") <> #{current_year}],
        )
      end
    end
  end
end
