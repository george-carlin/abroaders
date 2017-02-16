module Abroaders
  module Cell
    class MissingOptionsError < StandardError
      # @param opts [Array] a list of the names of the missing options
      def initialize(opts)
        super "missing option(s): #{opts.join(', ')}"
      end
    end

    # experimental. This module (which should be extended, not included)
    # provides what I feel is a glaring ommision from Trailblazer::Cell - a
    # simple one-line class method that defines getters for the `options` hash.
    #
    # Also lets you specify that an option is required (actually, options are
    # required by default), meaning that if you forget to add it, an error will
    # be raised on .call.
    #
    #     class TravelPersonSummary < Trailblazer::Cell
    #       extend Abroaders::Cell::Options
    #
    #       # define private instance methods `editable` and `assigned_admin`:
    #       option :editable
    #       option :assigned_admin, optional: true
    #     end
    #
    #     cell(TravelPersonSummary, nil)
    #     # => MissingOptionsError missing option 'editable'
    module Options
      def call(model = nil, opts = {}, &block)
        missing_keys = @__abroaders_required_options - opts.keys
        raise MissingOptionsError, missing_keys if missing_keys.any?
        super
      end

      def option(name, optional: false)
        unless optional
          @__abroaders_required_options ||= []
          @__abroaders_required_options << name
        end

        define_method name do
          options[name]
        end

        private name
      end
    end
  end
end
