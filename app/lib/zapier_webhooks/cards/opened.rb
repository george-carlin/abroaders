module ZapierWebhooks
  module Cards
    # Inform Zapier that a card has been opened (by a user or admin)
    #
    # At present this webhook only cares about cards which have been opened AND
    # which have an offer - which means the card must be a recommendation,
    # because there's currently no way to create a card account with an offer
    # unless the card was originally recommended by an admin.
    #
    # It's up to the caller to enforce this; the job will raise an error if
    # passed a card that doesn't have an offer. It'll also raise if the card is
    # opened, but be careful not to call it every time a card is updated and
    # opened_on is present: make sure it's only called when it's updated,
    # opened_on is present, AND opened_on wasn't present before the update.
    # (The Job has no way of distinguishing between these two scenarios, so
    # again it's up to the caller to get it right.)
    class Opened < Job
      PATH = '/96825/5bw0ja/'.freeze

      # @option opts [Integer] card_id ID of the Card
      def perform(opts = {})
        card = Card.find(opts.fetch(:id))
        raise 'card must have offer' unless card.offer?
        raise 'card must be opened' unless card.opened?

        p_type = card.person.type.capitalize

        tag2 = [
          card.card_product.id,
          Offer::Cell::Description.(card.offer),
          p_type,
        ].join('-')

        Client.post(
          PATH,
          body: {
            data: {
              'email' => card.account.email,
              # This is a weird format, but it's how Erik's setup expects it:
              'tag' => "#{card.offer.id}-#{p_type}",
              'name' => card.person.first_name,
              'tag2' => tag2,
            },
          },
        )
      end
    end
  end
end
