module CardAccount::Statuses
  extend ActiveSupport::Concern

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
