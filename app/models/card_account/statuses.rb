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
  # (statuses in brackets may be skipped)
  #
  # recommended
  #     ├─▸ declined
  #     └─▸ (pending_decision)
  #              ├─▸ denied
  #              │     ├─▸ declined_to_apply_for_reconsideration
  #              │     └─▸ (pending_reconsideration_decision)
  #              │           ├─▸ denied_after_reconsideration
  #              │           └─▸ approved_after_reconsideration
  #              └─▸ approved (AKA = currently working on bonus challenge)
  #                    └─▸ closed
  #


  STATUSES = %i[
    recommended
    declined
    reconsideration
    pending_decision
    manual_pending
    denied
    manual_denied
    bonus_challenge
    open
    closed
    converted
  ]

  included do
    enum status: STATUSES
  end

  def declined_at=(*args)
    self.applied_at = *args
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

end
