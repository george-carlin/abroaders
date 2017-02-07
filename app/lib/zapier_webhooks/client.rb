module ZapierWebhooks
  class Client
    include HTTParty
    base_uri 'https://hooks.zapier.com/hooks/catch'
  end
end
