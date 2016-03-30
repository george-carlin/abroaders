class SpendingSurvey < Form

  def initialize(account)
    @account = account
    account_must_be_in_correct_onboarding_stage!

    self.main_passenger_has_business = "no_business"

    if has_companion?
      self.companion_has_business = "no_business"
    end
  end

  # ----- ATTRIBUTES -----

  attr_reader :account
  delegate :has_companion?, to: :account
  delegate :shares_expenses?, to: :account, prefix: true

  attr_accessor :companion_business_spending,
                :companion_credit_score,
                :companion_has_business,
                :companion_personal_spending,
                :main_passenger_business_spending,
                :main_passenger_credit_score,
                :main_passenger_has_business,
                :main_passenger_personal_spending,
                :shared_spending

  def companion_has_business?
    %w[with_ein without_ein].include?(companion_has_business)
  end

  def main_passenger_has_business?
    %w[with_ein without_ein].include?(main_passenger_has_business)
  end

  attr_boolean_accessor :companion_will_apply_for_loan,
                        :main_passenger_will_apply_for_loan

  def save
    super do
      main = account.main_passenger.build_spending_info
      main.credit_score        = main_passenger_credit_score
      main.has_business        = main_passenger_has_business
      main.will_apply_for_loan = main_passenger_will_apply_for_loan

      if main_passenger_has_business?
        main.business_spending = main_passenger_business_spending
      else
        main.business_spending = nil
      end

      if has_companion?
        comp = account.companion.build_spending_info

        if account_shares_expenses?
          # To eliminate the need for an extra DB column that will be null
          # most of the time: when spending is shared, it's stored internally
          # under main_passenger.personal_spending, and
          # companion.personal_spending is left blank.
          main.personal_spending = shared_spending
          # Except we have to make it 0, not nil, because the DB column isn't
          # nullable :(
          comp.personal_spending = 0
        else
          comp.personal_spending = companion_personal_spending
        end

        if companion_has_business?
          comp.business_spending = companion_business_spending
        else
          comp.business_spending = nil
        end

        comp.credit_score        = companion_credit_score
        comp.has_business        = companion_has_business
        comp.will_apply_for_loan = companion_will_apply_for_loan
      end

      if !(has_companion? && account_shares_expenses?)
        main.personal_spending = main_passenger_personal_spending
      end

      @account.onboarding_stage = "main_passenger_cards"
      @account.save!(validate: false)
      main.save!(validate: false)
      comp.save!(validate: false) if has_companion?
    end
  end

  # Validations

  CREDIT_SCORE_NUMERICALITY_VALIDATIONS = {
    # avoid duplicate error message (from presence validation) when nil:
    allow_blank: true,
    greater_than_or_equal_to: SpendingInfo::MINIMUM_CREDIT_SCORE,
    less_than_or_equal_to:    SpendingInfo::MAXIMUM_CREDIT_SCORE,
  }

  SPENDING_NUMERICALITY_VALIDATIONS = {
    # avoid duplicate error message (from presence validation) when nil:
    allow_blank: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
  }

  validates :main_passenger_credit_score,
    numericality: CREDIT_SCORE_NUMERICALITY_VALIDATIONS,
    presence: true

  validates :main_passenger_personal_spending,
    numericality: SPENDING_NUMERICALITY_VALIDATIONS,
    presence: true,
    unless: "has_companion? && account_shares_expenses?"

  validates :main_passenger_business_spending,
    numericality: SPENDING_NUMERICALITY_VALIDATIONS,
    presence: true,
    if: :main_passenger_has_business?

  validates :companion_credit_score,
    numericality: CREDIT_SCORE_NUMERICALITY_VALIDATIONS,
    presence: true,
    if: :has_companion?

  validates :companion_personal_spending,
    numericality: SPENDING_NUMERICALITY_VALIDATIONS,
    presence: true,
    if: "has_companion? && !account_shares_expenses?"

  validates :companion_business_spending,
    numericality: SPENDING_NUMERICALITY_VALIDATIONS,
    presence: true,
    if: "has_companion? && companion_has_business?"

  validates :shared_spending,
    numericality: SPENDING_NUMERICALITY_VALIDATIONS,
    presence: true,
    if: :account_shares_expenses?

  private

  def account_must_be_in_correct_onboarding_stage!
    # Sanity checks:
    raise unless @account.onboarding_stage == "spending"
    raise if @account.main_passenger.spending_info&.persisted?
    if @account.has_companion?
      raise if @account.companion.spending_info&.persisted?
    else
      # you can't share expenses if you don't have a companion:
      raise if @account.shares_expenses?
    end
  end

end
