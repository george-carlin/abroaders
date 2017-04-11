module Abroaders
  module Cell
    # A `<span>` with some text and with data attributes that can be activated
    # by JS to make a Bootstrap tooltip.
    class SpanWithTooltip < Abroaders::Cell::Base
      # Don't use a 'model'; let the caller pass in an options hash as the
      # *first* argument.
      #
      # @option opts [String] text the visible text within the <span>
      # @option opts [String] tooltip_text the text shown on mouseover
      def initialize(opts, *)
        super(nil, opts)
      end

      def show
        content_tag(
          :span,
          options.fetch(:text),
          class: 'SpanWithTooltip',
          data: { title: options.fetch(:tooltip_text), toggle: 'tooltip' },
        )
      end
    end
  end
end
