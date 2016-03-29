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
    %w[with_ein without_ein].include?(main_passenger_has_business)
  end

  def main_passenger_has_business?
    %w[with_ein without_ein].include?(main_passenger_has_business)
  end

  attr_boolean_accessor :companion_will_apply_for_loan,
                        :main_passenger_will_apply_for_loan

  def save
    super do
      main = account.main_passenger.build_spending_info
      main.business_spending   = main_passenger_business_spending
      main.credit_score        = main_passenger_credit_score
      main.has_business        = main_passenger_has_business
      main.will_apply_for_loan = main_passenger_will_apply_for_loan

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

        comp.business_spending   = companion_business_spending
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

  CREDIT_SCORE_VALIDATIONS = {
    numericality: {
      greater_than_or_equal_to: SpendingInfo::MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    SpendingInfo::MAXIMUM_CREDIT_SCORE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  }

  SPENDING_NUMERICALITY_VALIDATIONS = {
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
      # avoid duplicate error message (from presence validation) when nil:
      allow_nil: true
    }
  }

  validates :main_passenger_credit_score,
    CREDIT_SCORE_VALIDATIONS.merge(presence: true)
  validates :main_passenger_personal_spending, {
    numericality: SPENDING_NUMERICALITY_VALIDATIONS.merge(
      unless: "has_companion? && account_shares_expenses?"
    ),
    presence: { unless: "has_companion? && account_shares_expenses?" }
  }

  with_options if: :main_passenger_has_business? do |survey|
    survey.validates :main_passenger_business_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
    }
  end

  with_options if: :has_companion? do |survey|
    survey.validates :companion_credit_score,
      CREDIT_SCORE_VALIDATIONS.merge(presence: true)

    survey.validates :companion_personal_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: { if: "has_companion? && !account_shares_expenses?" }
    }
  end

  with_options if: "has_companion? && companion_has_business?" do |survey|
    survey.validates :companion_business_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
    }
  end

  with_options if: :account_shares_expenses? do
    validates :shared_spending,
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
  end

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
