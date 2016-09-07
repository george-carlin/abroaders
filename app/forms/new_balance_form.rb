class NewBalanceForm < BalanceForm
  attribute :currency_id, Fixnum

  validates :currency_id, presence: true

  private

  def persist!
    Balance.create!(
      currency_id: currency_id,
      person_id:   person_id,
      value:       value
    )
  end
end
