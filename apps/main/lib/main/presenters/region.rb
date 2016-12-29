require_dependency 'abroaders/presenter'

module Main
  module Presenters
    class Region < Abroaders::Presenter
      include ActionView::Helpers::AssetTagHelper

      def image
        image_tag("regions/#{code}.jpg", class: 'region-image', style: 'width:100%')
      end
    end
  end
end
