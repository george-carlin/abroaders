class BankForm < ApplicationForm
  attribute :name, String
  attribute :personal_phone, String
  attribute :business_phone, String

  def self.name
    "Bank"
  end

  # Validations

  validates :name, presence: true

  private

  def bank_params
    {
      name: name,
      business_phone: business_phone,
      personal_phone: personal_phone
    }
  end
end
