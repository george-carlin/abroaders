class SpendingSurvey < SpendingForm
  private

  def persist!
    person.create_spending_info!(spending_info_attributes)
  end
end
