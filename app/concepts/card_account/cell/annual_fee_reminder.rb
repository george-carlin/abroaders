class CardAccount < CardAccount.superclass
  module Cell
    # Body of email that is sent to a user on the first day of the month
    # when they have open card accounts with an annual fee due that month.
    #
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

      def cards_for_each_person
        hash = options.fetch(:cards).group_by(&:person)
        # we could just pass this hash as the `collection:` option, but then
        # there's no guarantee that the people will be in the right order, so
        # we need an extra step:
        cards = [[owner, hash[owner]], [companion, hash[companion]]]
        cell(CardsForPerson, collection: cards, couples?: couples?)
      end

      def link
        url = 'http://www.abroaders.com/annual-fee-negotiation/'
        link_to(url, url)
      end

      # model: an array that looks like this:
      #   [<Person>, Array<Card>]
      class CardsForPerson < Abroaders::Cell::Base
        include Escaped

        option :couples?

        def show
          header << card_list
        end

        private

        def cards
          model[1] || []
        end

        def card_list
          if cards.empty?
            return '' unless couples?
            "#{first_name} has no cards with an annual fee due this month"
          else
            content_tag :ul do
              cell(CardBulletPoint, collection: cards)
            end
          end
        end

        def first_name
          escape!(person.first_name)
        end

        # The header says which person the card accounts belong to. It's only
        # necessary to display it when the account is a couples account.
        def header
          return '' unless couples? && cards.any?
          "<p>#{first_name}'s cards:</p>"
        end

        def person
          model[0]
        end
      end

      # @!method self.call(card, options = {})
      #   @param card [Card] a card account
      class CardBulletPoint < Abroaders::Cell::Base
        property :card_product
        property :id

        def show
          "<p id='card_#{id}'>#{annual_fee} - #{product_name}</p>"
        end

        private

        def annual_fee
          number_to_currency(card_product.annual_fee)
        end

        def product_name
          cell(CardProduct::Cell::FullName, card_product, with_bank: true)
        end
      end
    end
  end
end
