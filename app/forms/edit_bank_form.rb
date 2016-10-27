class EditBankForm < BankForm
  attribute :id

  def self.find(id)
    new(::Bank.find(id).attributes)
  end

  def persisted?
    true
  end

  def bank
    @bank ||= Bank.find(id)
  end

  private

  def persist!
    bank.update!(bank_params)
  end
end
