class PhoneNumberForm < ApplicationForm
  attribute :account,      Account
  attribute :phone_number, String

  validates :phone_number, presence: true, length: { maximum: 20 }

  def self.model_name
    Account.model_name
  end

  private

  def persist!
    AccountOnboarder.new(account).add_phone_number!
    account.update!(phone_number: phone_number.strip)
  end
end
