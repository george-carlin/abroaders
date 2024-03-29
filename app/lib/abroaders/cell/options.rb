module Abroaders
  module Cell
    class MissingOptionsError < StandardError
      # @param opts [Array] a list of the names of the missing options
      def initialize(opts)
        super "missing option(s): #{opts.join(', ')}"
      end
    end

    # This module provides what I feel is a glaring omission from Cells itself
    # - a simple one-line class method that defines getters for the `options`
    # hash, similar to how the `property` class method lets you define getters
    # for the model.
    #
    # Options are required by default. If a required option isn't provided when
    # the cell is initialized, an error will be raised. To make an option
    # non-required, pass `optional: true`.
    #
    # You can also define a default option with the `default:` key. Setting a
    # `default:` implies that `optional:` is true.
    #
    #     class TravelPlanSummary < Abroaders::Cell::Base
    #       include Abroaders::Cell::Options
    #
    #       # define private instance methods `editable` and `assigned_admin`:
    #       option :editable
    #       option :assigned_admin, optional: true
    #       option :deletable, default: false
    #     end
    #
    #     cell(TravelPersonSummary, nil)
    #     # => MissingOptionsError missing option 'editable'
    module Options
      def self.extended(*)
        raise "include Options, don't extend it"
      end

      def self.included(base)
        base.extend ClassMethods
      end

      def initialize(model = nil, opts = {}, &block)
        missing_keys = self.class.__abroaders_required_options - opts.keys
        raise MissingOptionsError, missing_keys if missing_keys.any?
        super
      end

      module ClassMethods
        # Note that you can't extend the generated method by overriding it, e.g. this won't work:
        #
        #     option :name
        #
        #     def name
        #       super.capitalize
        #     end
        #
        # ... because this is equivalent to writing `def name` twice
        # in the same class; the first definition gets ignored.
        #
        # If you look in the source code for some of the Trailblazer gems,
        # there's a way around this by defining methods within a module then
        # including that module into the class. But for now it's not worth
        # the effort to do something similar here. Just do something like
        # this instead, skipping the `option` class method:
        #
        #     def name
        #       options.fetch(:name).capitalize
        #     end
        #
        def option(name, opts = {})
          optional = opts.key?(:default) || opts.fetch(:optional, false)
          __abroaders_required_options << name unless optional

          define_method(name) do
            if opts.key?(:default)
              options.fetch(name, opts[:default])
            else
              options[name]
            end
          end

          private name
        end

        def __abroaders_required_options
          @__abroaders_required_options ||= []
        end
      end
    end
  end
end
