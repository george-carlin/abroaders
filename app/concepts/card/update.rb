class Card < Card.superclass
  # Generic 'Update' operation that can be used by CardAccount and
  # CardRecommendation ops (and their admin counterparts). Each of these child
  # ops will use a different edit operation with a different contract object;
  # set the 'edit_op' setting to the operation class to determine this edit op
  # at runtime.
  #
  # Doing it this way makes update ops much more DRY. It also means that if we
  # want to hook in extra behaviour that must run every time a card is updated
  # (e.g.  triggering a Zapier webhook), we only have to add it in one place.
  class Update < Trailblazer::Operation
    module EditOperation
      extend Uber::Callable

      def self.call(options)
        options['edit_op']
      end
    end

    step Nested(EditOperation)
    step Contract::Validate(key: :card)
    step Contract::Persist()
  end
end
