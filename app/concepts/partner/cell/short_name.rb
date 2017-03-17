module Partner
  module Cell
    # takes one of the following strings:
    #
    # 'card_ratings'
    # 'credit_cards'
    # 'award_wallet'
    # 'card_benefit'
    #
    # ... and just returns an abbreviation. If we ever upgrade Partner
    # to a full DB-backed model, this cell might become more complicated
    class ShortName < Abroaders::Cell::Base
      def show
        case model
        when 'card_ratings' then 'CR'
        when 'credit_cards' then 'CC'
        when 'award_wallet' then 'AW'
        when 'card_benefit' then 'CB'
        else '-'
        end
      end
    end
  end
end
