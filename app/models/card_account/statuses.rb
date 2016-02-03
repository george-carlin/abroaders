module CardAccount::Statuses
  extend ActiveSupport::Concern

  # 'declined' means the user would not, or could not, apply for the card
  #            which we recommended to them.
  # 'denied' means that the user applied for the card, but the application
  #          was denied by the bank.
  #
  #
  # FLOW
  #
  # Here's the way which a card account may pass through the statuses:
  #
  # (statuses in brackets may be skipped. The boolean after the comma
  # is the value of the 'reconsidered' column.)
  #
  # recommended, false
  #     ├─▸ declined, false
  #     ├─▸ denied, false
  #     │     ├─▸ declined, true
  #     │     ├─▸ denied, true
  #     │     └─▸ open, true
  #     │           └─▸ closed, true
  #     └─▸ open, false
  #           └─▸ closed, false
  #
  # TODO confirm with Erik: in previous sketches, we had an extra
  # stage called 'pending_decision', but for the sake of simplicity
  # I've decided not to store it. Can we get away with this?


  STATUSES = %i[
    unknown
    recommended
    declined
    denied
    open
    closed
  ]


  included do
    enum status: STATUSES
  end

  def declined_at=(datetime)
    self.applied_at = datetime
  end

  def applied_at
    declined? ? nil : read_attribute(:applied_at)
  end

  def declined_at
    declined? ? read_attribute(:applied_at) : nil
  end

  def decline!
    update_attributes!(applied_at: Time.now, status: :declined)
  end

  concerning :SafetyChecks do
    def applyable?
      status == "recommended"
    end

    def declinable?
      status == "recommended"
    end

    def deniable?
      status == "recommended"
    end

    def openable?
      status == "recommended"
    end
    alias_method :acceptable?, :openable?
  end

end
