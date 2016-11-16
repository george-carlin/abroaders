module AdminArea
  module Card
    # Hack to make the routes work with `namespace :cards`
    class OffersController < ::AdminArea::OffersController
    end
  end
end
