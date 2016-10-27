class NewBankForm < BankForm
  private

  def persist!
    ::Bank.create!(bank_params)
  end
end
