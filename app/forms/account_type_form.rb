class AccountTypeForm < ApplicationForm
  attribute :account,              Account
  attribute :type,                 String # 'solo' or 'couples'
  attribute :companion_first_name, String

  validates :companion_first_name,
            presence: { if: :couples? },
            absence: { if: :solo? }
  validates :type, inclusion: { in: %w[solo couples] }

  private

  def persist!
    account.create_companion!(first_name: companion_first_name) if couples?
    AccountOnboarder.new(current_account).choose_account_type!
  end

  def solo?
    type == 'solo'
  end

  def couples?
    type == 'couples'
  end
end
