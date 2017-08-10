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
    self['opened_webhook'] = ZapierWebhooks::Cards::Opened

    module EditOperation
      extend Uber::Callable

      def self.call(options)
        options['edit_op']
      end
    end

    step Nested(EditOperation)
    success :note_whether_card_is_unopened
    step Contract::Validate(key: :card)
    step Contract::Persist()
    success :trigger_card_opened_webhook

    private

    def note_whether_card_is_unopened(opts, model:, **)
      opts['was_unopened'] = model.unopened?
    end

    def trigger_card_opened_webhook(model:, was_unopened:, **)
      if was_unopened && model.opened? && model.offer? &&
         model.opened_on >= 15.days.ago
        # Strangely, class-level settings aren't inherited, meaning
        # that when you . Not sure if this
        # is deliberate or on oversight (looking in the TRB source I see that
        # it's because the settings are stored as an instance variable on the
        # class, so it's not inherited by default.) Opened an issue about it
        # at https://github.com/trailblazer/trailblazer/issues/185, but in
        # the meantime we'll have to do it like thisL
        self.class.superclass['opened_webhook'].perform_later(id: model.id)
      end
    end
  end
end
