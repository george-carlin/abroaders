class Card < ApplicationRecord
  class Form < Reform::Form
    feature Reform::Form::MultiParameterAttributes

    property :closed, virtual: true, prepopulator: ->(_) { self.closed = !closed_at.nil? }
    property :closed_at
    property :opened_at

    validation do # TODO convert to use dry-validation
      validates :opened_at, presence: true

      validate :closed_when_closed
      validate :not_opened_in_the_future
      validate :not_closed_in_the_future
      validate :opened_before_closed
    end

    def closed=(value)
      super(::Types::Form::Bool[value])
    end

    def self.model_name
      Card.model_name # TODO this shouldn't be necessary, should it?
    end

    private

    def closed_when_closed
      errors.add(:closed_at, :blank) if !closed.nil? && closed && closed_at.nil?
    end

    def not_opened_in_the_future
      if !opened_at.nil? && opened_at > Date.today
        errors.add(:opened_at, I18n.t('errors.not_in_the_future?'))
      end
    end

    def not_closed_in_the_future
      if !closed_at.nil? && closed_at > Date.today
        errors.add(:closed_at, I18n.t('errors.not_in_the_future?'))
      end
    end

    def opened_before_closed
      if closed && !closed_at.nil? && !opened_at.nil? && closed_at < opened_at
        errors.add(:closed_at, 'must be later than opened date')
      end
    end
  end
end
