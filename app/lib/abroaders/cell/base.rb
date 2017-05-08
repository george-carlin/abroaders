module Abroaders
  module Cell
    class Base < Trailblazer::Cell
      include Abroaders::Cell::Options

      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::NumberHelper
      include BootstrapOverrides
      include FontAwesome::Rails::IconHelper

      # this include is necessary otherwise the specs fail; appears to be
      # a bug in Cells. See https://github.com/trailblazer/cells/issues/298
      include ::Cell::Erb

      private

      # Shorthand for cells to use the cookies from parent_controller. Use
      # sparingly
      def cookies
        request.cookie_jar
      end

      def escape(*args)
        warn "Abroaders::Cell::Base#escape is deprecated. Include the Escaped "\
             "module and use #escape! instead"
        warn "Called from #{self.class}"
        ERB::Util.html_escape(*args)
      end

      def flash
        request.flash
      end

      def t(*args)
        I18n.t(*args)
      end

      # Worth noting here (in case I ever feel compelled to investigate again)
      # that `request.params` and `params` aren't quite the same in Rails.  The
      # former is a HashWithIndifferentAccess, while the latter is an
      # ActionController::Parameters. I imagine they always have the same
      # keys/values as each other but I haven't looked in the Rails source to
      # check.
      #
      # Trailblazer::Cell#params (provided by the cells-rails gem) delegates to
      # controller.params, not controller.request.params.
    end
  end
end
