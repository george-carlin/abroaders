module Notifications
  class NewRecommendationsPresenter < ApplicationPresenter
    # Right now we only have one kind of notification, so let's keep it super
    # simple for now and wait until the new theme is in place before adding
    # any more:
    def list_item
      h.content_tag_for :li, self, class: "notification" do
        h.link_to(
          "You have received new recommendations - Click to view",
          h.notification_path(self),
        )
      end
    end
  end
end
