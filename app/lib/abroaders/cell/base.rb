module Abroaders
  module Cell
    class Base < Trailblazer::Cell
      include Abroaders::Cell::Options

      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::NumberHelper
      include ActionView::Helpers::RecordTagHelper
      include BootstrapOverrides
      include FontAwesome::Rails::IconHelper

      # this include is necessary otherwise the specs fail; appears to be
      # a bug in Cells. See https://github.com/trailblazer/cells/issues/298 FIXME
      include ::Cell::Erb
    end
  end
end
