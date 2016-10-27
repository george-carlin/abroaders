class EditBalanceForm < BalanceForm
  def persisted?
    true
  end

  private

  def persist!
    Balance.update(id, value: avalue)
  end
end
