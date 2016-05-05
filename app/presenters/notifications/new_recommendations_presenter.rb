module Notifications
  class NewRecommendationsPresenter < ApplicationPresenter

    # Right now we only have one kind of notification, so let's keep it super
    # simple for now and wait until the new theme is in place before adding
    # any more:
    def link
      h.content_tag :li do
        h.link_to "New recommendations", h.notification_path(self)
      end
    end

  end
end
