class SpendingSurvey < Form

  SPENDING_INFO_GETTERS = %i[
    business_spending
    credit_score
    has_business
    personal_spending
    will_apply_for_loan
  ]

  SPENDING_INFO_SETTERS = SPENDING_INFO_GETTERS.map { |g| :"#{g}=" }

  SPENDING_INFO_ACCESSORS = SPENDING_INFO_GETTERS + SPENDING_INFO_SETTERS

  attr_accessor :account, :main_passenger, :companion, :main_info,
    :companion_info, :has_companion

  delegate(*SPENDING_INFO_ACCESSORS, to: :main_info, prefix: true)
  delegate(*SPENDING_INFO_ACCESSORS, to: :companion_info, prefix: true)

  alias_attribute "has_companio", :has_companion

  def initialize(account, params={})
    self.account = account
    # Sanity checks:
    raise unless account.main_passenger.try(:persisted?)
    raise if account.main_passenger.spending_info.try(:persisted?)

    self.main_passenger = account.main_passenger
    self.main_info      = main_passenger.build_spending_info

    self.has_companion  = account.has_companion?

    if account.has_companion?
      raise if account.companion.spending_info.try(:persisted?)
      self.companion      = account.companion
      self.companion_info = companion.build_spending_info
    end
  end

  CREDIT_SCORE_VALIDATIONS = {
    numericality: {
      greater_than_or_equal_to: SpendingInfo::MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    SpendingInfo::MAXIMUM_CREDIT_SCORE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  }

  SPENDING_VALIDATIONS = {
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  }

  validates :main_info_credit_score,
    CREDIT_SCORE_VALIDATIONS.merge(presence: true)
  validates :main_info_personal_spending,
    SPENDING_VALIDATIONS.merge(presence: true)
  validates :main_info_business_spending,
    SPENDING_VALIDATIONS.merge(presence: true)

  validates :companion_spending_credit_score,
    CREDIT_SCORE_VALIDATIONS.merge(presence: :has_companion?)
  validates :companion_spending_personal_spending,
    SPENDING_VALIDATIONS.merge(presence: :has_companion?)
  validates :companion_spending_business_spending,
    # TODO will this cause an error when the input is blank?
    SPENDING_VALIDATIONS.merge(presence: :has_companion?)

end
