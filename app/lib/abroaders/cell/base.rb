# Make sure ActionView::Base is loaded otherwise we can get a weird error where
# kaminari-cells tries a use a module before it defines it.
require 'action_view/base'

module Abroaders
  module Cell
    class Base < Trailblazer::Cell
      include Abroaders::Cell::Options

      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::FormOptionsHelper
      include ActionView::Helpers::NumberHelper
      include BootstrapOverrides
      include FontAwesomeHelper

      # this include is necessary otherwise the specs fail; appears to be
      # a bug in Cells. See https://github.com/trailblazer/cells/issues/298
      include ::Cell::Erb

      # If you have multiple cells in an inheritance hierarchy, by default each
      # cell uses its own view:
      #
      #     # renders foo.erb:
      #     class Foo < Abroaders::Cell::Base
      #     end
      #
      #     # renders bar.erb:
      #     class Bar < Foo
      #     end
      #
      # But sometimes you don't want the subclass to use an entirely separate
      # view file, it might just override specific methods that are called
      # within the parent view file. Call this method in the parent class to
      # make all subclasses use the parent's view file.
      #
      #     class Foo < Abroaders::Cell::Base
      #       # makes both cells render foo.erb:
      #       subclasses_use_parent_view!
      #     end
      #
      #     class Bar < Foo
      #     end
      #
      def self.subclasses_use_parent_view!
        define_method :show do
          ancestors = self.class.ancestors.select { |c| c.is_a?(Class) }
          superclass = ancestors[ancestors.index(::Abroaders::Cell::Base) - 1]
          parts = superclass.to_s.split('::')
          render view: parts[(parts.index('Cell') + 1)..-1].join('::').underscore
        end
      end

      private

      # Shorthand for cells to use the cookies from parent_controller. Use
      # sparingly
      def cookies
        request.cookie_jar
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
