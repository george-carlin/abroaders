# Form object to create a SpendingInfo record for an account's owner,
# and for the account's companion if it has one. Also saves the
# 'monthly_spending_usd' info for the account.
#
#   survey = SpendingSurvey.new(account: account)
#   survey.update_attributes!(
#     monthly_spending: 1234,
#     owner_business_spending_usd: 555,
#     owner_credit_score: 350,
#     owner_has_business: "with_ein",
#     owner_will_apply_for_loan: true,
#   )
#   # => creates account.owner.spending_info
class SpendingSurvey < ApplicationForm
  attribute :account, Account
  attribute :monthly_spending, Integer

  %i[owner companion].each do |person|
    attribute "#{person}_business_spending_usd", Integer
    attribute "#{person}_credit_score",          Integer
    attribute "#{person}_has_business",          String
    attribute "#{person}_will_apply_for_loan",   Boolean
  end

  def initialize(*args)
    super
    self.owner_has_business     = "no_business"
    self.companion_has_business = "no_business" if account&.companion
    self.owner_will_apply_for_loan     = false
    self.companion_will_apply_for_loan = false if account&.companion
  end

  def self.model_name
    SpendingInfo.model_name
  end

  validates :monthly_spending,
            presence: true,
            numericality: { allow_blank: true, greater_than_or_equal_to: 0 }

  BUSINESS_SPENDING_VALIDATIONS = {
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
    },
  }.freeze

  CREDIT_SCORE_VALIDATIONS = {
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: ::SpendingInfo::MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    ::SpendingInfo::MAXIMUM_CREDIT_SCORE,
    },
  }.freeze

  HAS_BUSINESS_VALIDATIONS = {
    inclusion: { in: %w[with_ein without_ein no_business], allow_blank: true },
  }.freeze

  # ---- owner spending validations ----

  validates_absence_of(
    :owner_business_spending_usd,
    :owner_credit_score,
    :owner_has_business,
    unless: :require_owner_spending?,
  )

  validates :owner_business_spending_usd,
            BUSINESS_SPENDING_VALIDATIONS.merge(
              presence: { if: :require_owner_business_spending? },
            )

  with_options presence: { if: :require_owner_spending? } do
    validates :owner_credit_score, CREDIT_SCORE_VALIDATIONS
    validates :owner_has_business, HAS_BUSINESS_VALIDATIONS
  end

  # ---- companion spending validations ----

  validates_absence_of(
    :companion_business_spending_usd,
    :companion_credit_score,
    :companion_has_business,
    unless: :require_companion_spending?,
  )

  validates :companion_business_spending_usd,
            BUSINESS_SPENDING_VALIDATIONS.merge(
              presence: { if: :require_companion_business_spending? },
            )

  with_options presence: { if: :require_companion_spending? } do
    validates :companion_credit_score, CREDIT_SCORE_VALIDATIONS
    validates :companion_has_business, HAS_BUSINESS_VALIDATIONS
  end

  private

  def persist!
    if require_owner_spending?
      account.owner.create_spending_info!(
        business_spending_usd: owner_business_spending_usd,
        credit_score:          owner_credit_score,
        has_business:          owner_has_business,
        will_apply_for_loan:   owner_will_apply_for_loan,
      )
    end
    if require_companion_spending?
      account.companion.create_spending_info!(
        business_spending_usd: companion_business_spending_usd,
        credit_score:          companion_credit_score,
        has_business:          companion_has_business,
        will_apply_for_loan:   companion_will_apply_for_loan,
      )
    end
    AccountOnboarder.new(account).add_spending!
    account.update_attributes!(monthly_spending_usd: monthly_spending)
  end

  def owner_has_business?
    %w[with_ein without_ein].include?(owner_has_business)
  end

  def companion_has_business?
    %w[with_ein without_ein].include?(companion_has_business)
  end

  def require_owner_spending?
    account.owner.eligible?
  end

  def require_owner_business_spending?
    require_owner_spending? && owner_has_business?
  end

  def require_companion_spending?
    account.companion.present? && account.companion.eligible?
  end

  def require_companion_business_spending?
    require_companion_spending? && companion_has_business?
  end
end
