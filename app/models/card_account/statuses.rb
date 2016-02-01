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
  #     └─▸ (pending_decision, false)
  #              ├─▸ denied, false
  #              │     ├─▸ declined, true
  #              │     └─▸ (pending_decision, true)
  #              │           ├─▸ denied, true
  #              │           └─▸ open, true
  #              │                └─▸ closed, false
  #              └─▸ open, false
  #                    └─▸ closed, false
  #


  STATUSES = %i[
    recommended
    declined
    pending_decision
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
      %w[recommended pending_decision].include?(status)
    end

    def openable?
      %w[recommended pending_decision].include?(status)
    end
    alias_method :acceptable?, :openable?
  end

end
