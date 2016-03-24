class Passenger < ApplicationRecord

  # Attributes

  enum citizenship:  [ :us_citizen, :us_permanent_resident, :neither]

  def full_name
    [first_name, middle_names, last_name].compact.join(" ")
  end

  alias_attribute :main_passenger?, :main

  def companion?
    !main?
  end

  def has_added_spending?
    spending_info.try(:persisted?)
  end

  delegate :time_zone, :onboarded?, :email, to: :account
  delegate :credit_score, :will_apply_for_loan, :personal_spending,
    :business_spending, :has_business, :has_business?, :has_business_with_ein?,
    :has_business_without_ein?, :no_business?,
    to: :spending_info, allow_nil: true

  # The passenger signed up on the date their *account* was created, not on the
  # date which they added their passenger info in the survey. (In practice this
  # will usually be on the same date anyway, but bear it in mind.)
  def signed_up
    account.created_at
  end

  # Validations

  validates :account, uniqueness: { scope: :main }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true

  # Associations

  belongs_to :account
  has_one :spending_info, dependent: :destroy

  has_many :card_accounts
  has_many :card_recommendations, -> { recommendations },
                                  class_name: "CardAccount"
  has_many :cards, through: :card_accounts

  has_many :balances
  has_many :currencies, through: :balances

  concerning :Readiness do
    included do
      has_one :readiness_status
      delegate :unreadiness_reason, to: :readiness_status, allow_nil: true
    end

    def readiness_status_given?
      !!readiness_status.try(:persisted?)
    end

    def ready_to_apply?
      !!readiness_status.try(:ready?)
    end

    def unready_to_apply?
      !ready_to_apply?
    end
  end


  # Callbacks

  auto_strip_attributes :first_name, :middle_names, :last_name, :phone_number

  # Scopes

  scope :main,      -> { where(main: true) }
  scope :companion, -> { where(main: false) }

  scope :onboarded, -> do
    joins(:account).where(
      accounts: { onboarding_stage: Account.onboarding_stages["onboarded"] }
    )
  end

end
