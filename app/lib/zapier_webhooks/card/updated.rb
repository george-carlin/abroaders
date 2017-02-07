module ZapierWebhooks
  module Card
    # Job to notify Zapier that a card has been updated
    #
    # Posts to the webhook with the card's attributes nested under the key 'data'
    class Updated < CRUD
      PATH = '/96825/hzf4ls/'.freeze

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
