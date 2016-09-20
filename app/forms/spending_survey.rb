class SpendingSurvey < SpendingForm
  private

  def persist!
    # Make sure not to save an unreadiness reason if the user is not ready.
    self.unreadiness_reason = nil if ready? || unreadiness_reason.blank?
    person.update_attributes!(
      ready:              ready,
      unreadiness_reason: unreadiness_reason
    )
    person.create_spending_info!(spending_info_attributes)
  end
end
