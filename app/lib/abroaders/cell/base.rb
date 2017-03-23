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

      private

      # Shorthand for cells to use the cookies from parent_controller. Use
      # sparingly
      def cookies
        request.cookie_jar
      end

      def escape(*args)
        ERB::Util.html_escape(*args)
      end

      def flash
        request.flash
      end

      def t(*args)
        I18n.t(*args)
      end
    end
  end
end
