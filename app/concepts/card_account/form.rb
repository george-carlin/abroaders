class CardAccount < CardAccount.superclass
  # Note that the card account's card_product_id will be set by a param in the URL,
  # rather than in the posted form data.
  class Form < Reform::Form
    feature Reform::Form::MultiParameterAttributes
    feature Reform::Form::Coercion

    property :closed, virtual: true, prepopulator: ->(_) { self.closed = !closed_on.nil? }
    property :closed_on
    property :opened_on

    validation do
      validates :opened_on, presence: true

      validate :closed_when_closed
      validate :not_opened_in_the_future
      validate :not_closed_in_the_future
      validate :opened_before_closed
    end

    def closed=(value)
      super(::Types::Form::Bool[value])
    end

    # Make sure that the card account's "closed_on" timestamp is set to nil if
    # the 'closed' checkbox wasn't checked
    def sync
      self.closed_on = nil unless closed
      super
    end

    private

    def closed_when_closed
      errors.add(:closed_on, :blank) if !closed.nil? && closed && closed_on.nil?
    end

    def not_opened_in_the_future
      if !opened_on.nil? && opened_on > Date.current
        errors.add(:opened_on, I18n.t('errors.not_in_the_future?'))
      end
    end

    def not_closed_in_the_future
      if !closed_on.nil? && closed_on > Date.current
        errors.add(:closed_on, I18n.t('errors.not_in_the_future?'))
      end
    end

    def opened_before_closed
      if closed && !closed_on.nil? && !opened_on.nil? && closed_on < opened_on
        errors.add(:closed_on, 'must be later than opened date')
      end
    end
  end
end
