module ZapierWebhooks
  module Card
    # Job to notify Zapier that a new card has been created
    #
    # Posts to the webhook with the card's attributes nested under the key 'data'
    class Created < CRUD
      PATH = '/96825/h8gjyo/'.freeze

      # opts: 'data'. The card's attributes
      def perform(opts = {})
        Client.post(
          PATH,
          body: { data: opts.fetch('data') },
        )
      end
    end
  end
end
