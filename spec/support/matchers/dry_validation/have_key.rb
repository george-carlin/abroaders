require 'dry-validation'

module Dry::Validation::Matchers
  class Key
    attr_reader :key

    module Filled
      def matches?(schema)
        super
        @matched &&= @when_not_filled.include?('must be filled')
      end

      def failure_message
        return unless super
        @failure_message << 'must be filled'
      end

      def filled
        self
      end

      def maybe
        raise "already marked as 'filled'"
      end
    end

    module Maybe
      def matches?(schema)
        super
        @matched &&= @when_not_filled.empty?
      end

      def failure_message
        return unless super
        @failure_message << 'may be empty'
      end

      def filled
        raise "already marked as 'maybe'"
      end

      def maybe
        self
      end
    end

    def initialize(key)
      @key = key
    end

    def matches?(schema)
      raise 'not a schema' unless schema.is_a?(Dry::Validation::Schema)
      @when_missing    = schema.call({}).messages[key] || []
      @when_not_filled = schema.call(key => nil).messages[key] || []
      @matched = true
    end

    def maybe
      extend Maybe
    end

    def filled
      extend Filled
    end

    def failure_message(type)
      return if @matched.nil? || @matched
      @failure_message = "expected the schema to have #{type} key called '#{key}' that "
    end
  end

  class HaveRequiredKey < Key
    def matches?(schema)
      super
      @matched &&= @when_missing.include?('is missing')
    end

    def failure_message
      return unless super('a required')
      @failure_message
    end
  end

  class HaveOptionalKey < Key
    def matches?(schema)
      super
      @matched &&= @when_missing.empty?
    end

    def failure_message
      return unless super('an optional')
      @failure_message
    end
  end

  def have_required_key(key)
    HaveRequiredKey.new(key)
  end

  def have_optional_key(key)
    HaveOptionalKey.new(key)
  end
end
