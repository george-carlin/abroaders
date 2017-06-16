class CardRecommendation < CardRecommendation.superclass
  # Simple function that takes a card recommendation and returns a simple
  # true/false value to tell you if the attributes make sense.
  #
  # This class doesn't look at the actual *value* of any attribute of the rec
  # (e.g. to validate that the applied date isn't later than the declined
  # date.) It just checks which attributes are *present*, and returns true iff
  # it makes logical sense for the particular combination of attributes to be
  # present together (e.g. it doesn't make sense for denied_at to be present if
  # applied_in isn't.)
  #
  # This isn't used to get detailed validation error messages like you'd expect
  # on a normal form - which is why it just returns true/false without giving
  # any more detail. The point of this class is to use it as failsafe to guard
  # against bad data slipping through in weird edge cases - e.g. if the usee
  # has the application survey open in two tabs and clicks 'I was approved' in
  # one tab but 'I was denied' in the other.
  class Validate
    def self.call(rec)
      new(rec).call
    end

    attr_reader :rec

    def initialize(rec)
      @rec = rec
    end

    # @!return [Boolean]
    def call
      return false unless rec.recommended?

      # max. one of these methods should return true for the same rec:
      rec_methods = [:declined?, :applied?, :expired?]
      return false if rec_methods.count { |m| rec.send(m) } > 1

      # decline reason must be present iff rec is declined:
      return false if rec.declined? ^ !rec.decline_reason.nil?

      # can't be opened unless applied:
      return false if rec.opened? && !rec.applied?
      # can't deny unless applied:
      return false if rec.denied? && !rec.applied?
      # can't nudge unless applied:
      return false if rec.nudged? && !rec.applied?

      # can't call unless denied:
      return false if rec.called? && !rec.denied?
      # can't be redenied if you didn't call:
      return false if rec.redenied? && !rec.called?
      # can't open card if app was irreversibly denied:
      return false if rec.opened? && (rec.redenied? || (rec.denied? && rec.nudged?))
      # can't be both nudged and called:
      return false if rec.nudged? && rec.called?
      # can't be both nudged and redenied:
      return false if rec.nudged? && rec.redenied?

      # if you've got this far, it's probably valid!
      true
    end
  end
end
