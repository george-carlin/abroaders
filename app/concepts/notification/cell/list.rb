class Notification < Notification.superclass
  module Cell
    class List < Abroaders::Cell::Base
      private

      def html_classes
        "dropdown #{'unseen_notifications' if length > 0}"
      end

      def length
        model.unseen_notifications_count
      end

      def new_notifications_label
        content_tag :span, length, class: 'label label-success' if length > 0
      end

      def title
        text = "You have #{pluralize(length, 'new notification')}"
        content_tag :div, text, class: 'title'
      end

      def unseen_notifications
        cell(Item, collection: model.unseen_notifications)
      end

      class Item < Abroaders::Cell::Base
        include ActionView::Helpers::RecordTagHelper

        def show
          # Right now we only have one kind of notification, so let's keep it super
          # simple for now:
          content_tag_for :li, model, class: 'notification' do
            link_to(
              'You have received new recommendations - Click to view',
              notification_path(model),
            )
          end
        end
      end
    end
  end
end
