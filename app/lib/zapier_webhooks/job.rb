module ZapierWebhooks
  class Job < ApplicationJob
    queue_as :zapier_webhooks

    def self.enqueue(model, representer_class:)
      return unless enabled?
      data = representer_class.new(model).as_json
      perform_later('data' => data)
    end

    def self.enabled?
      !!ENV['PERFORM_ZAPIER_WEBHOOK_JOBS']
    end
  end
end
