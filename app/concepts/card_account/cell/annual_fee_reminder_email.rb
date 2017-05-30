class CardAccount < CardAccount.superclass
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account]
    #   @option options [Collection<Card>] cards the card accounts whose annual fees
    #     are due
    class AnnualFeeReminder < Abroaders::Cell::Base
      include Escaped

      property :companion
      property :couples?
      property :owner
      property :owner_first_name
      property :people

      option :cards

      # Plain text, no HTML
      def text
        ::Nokogiri.HTML(show).text
      end

      private

      def explanation
        count = cards.size
        a_card = if count == 1
                   'a card'
                 else
                   "#{count} cards"
                 end
        "This is a friendly reminder that you have #{a_card} with an annual "\
        "fee scheduled to appear on your next billing statement:"
      end

      def cards_by_person
        @cards_by_person ||= options.fetch(:cards).group_by(&:person)
      end

      def link
        url = 'http://www.abroaders.com/annual-fee-negotiation/'
        link_to(url, url)
      end

      # @!method self.call(account, options = {})
      #   @param person [Person]
      #   @option options [Collection<Card>] cards
      #   @option options [Boolean] couples
      class Card < Abroaders::Cell::Base
      end
    end
  end
end
