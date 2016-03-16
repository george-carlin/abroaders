module Account::SurveyCompletion
  def has_added_balances?
    passengers.any? && passengers.all?(&:has_added_balances?)
  end

  def has_added_cards?
    passengers.any? && passengers.all?(&:has_added_cards?)
  end

  def has_added_passengers?
    passengers.any? && passengers.all?(&:persisted?)
  end

  def has_added_spending?
    passengers.any? && passengers.all?(&:has_added_spending?)
  end

  def survey_complete?
    has_added_passengers? && has_added_spending? && has_added_cards? &&
      has_added_balances?
  end
end
