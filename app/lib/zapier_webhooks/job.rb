module ZapierWebhooks
  class Job < ApplicationJob
    queue_as :zapier_webhooks

    class << self
      %w[later now].each do |whenever|
        define_method "perform_#{whenever}" do |*args|
          return unless enabled?
          super(*args)
        end
      end
    end

    def self.enabled?
      !!ENV['PERFORM_ZAPIER_WEBHOOK_JOBS']
    end
  end
end
