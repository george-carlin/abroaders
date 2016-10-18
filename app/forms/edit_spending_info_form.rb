class EditSpendingInfoForm < SpendingForm
  attribute :monthly_spending_usd, Integer

  def self.find(person)
    new(SpendingInfo.find_by(person: person).attributes
                    .merge(person: person, monthly_spending_usd: person.account.monthly_spending_usd),)
  end

  def persisted?
    true
  end

  def account
    person.account
  end

  # Validations

  validates :monthly_spending_usd,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  private

  def spending_info
    @spending_info ||= person.spending_info
  end

  def persist!
    account.update!(account_attributes)
    spending_info.update!(spending_info_attributes)
  end

  def account_attributes
    { monthly_spending_usd: monthly_spending_usd }
  end
end
