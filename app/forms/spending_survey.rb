class SpendingSurvey < SpendingForm
  private

  def persist!
    # Make sure not to save an unreadiness reason if the user is not ready.
    self.unreadiness_reason = nil if ready? || unreadiness_reason.blank?
    ready_on = ready? ? Time.now : nil

    person.update_attributes!(
      ready:              ready,
      unreadiness_reason: unreadiness_reason,
      ready_on:           ready_on
    )
    person.create_spending_info!(spending_info_attributes)
  end
end
