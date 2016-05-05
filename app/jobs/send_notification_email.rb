class SendNotificationEmail < ApplicationJob
  queue_as :default

  def perform(opts={})
    # TODO
    # notification = Notification.find(opts.fetch(:notification_id))
    # person  = notification.record
  end

end
