module Partner
  module Cell
    # takes one of the following strings:
    #
    # 'card_ratings'
    # 'credit_cards'
    # 'award_wallet'
    # 'card_benefit'
    #
    # ... and returns a human-friendly name. If we ever upgrade Partner to a
    # full DB-backed model, this cell might become more complicated
    class FullName < Abroaders::Cell::Base
      def show
        case model
        when 'card_ratings' then 'CardRatings.com'
        when 'credit_cards' then 'CreditCards.com'
        when 'award_wallet' then 'AwardWallet'
        when 'card_benefit' then 'CardBenefit'
        else 'None'
        end
      end
    end
  end
end
