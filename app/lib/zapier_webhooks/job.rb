module ZapierWebhooks
  class Job < ApplicationJob
    queue_as :zapier_webhooks

    def self.enabled?
      !!ENV['PERFORM_ZAPIER_WEBHOOK_JOBS']
    end
  end
end
