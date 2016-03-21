class SpendingSurvey < Form

  def initialize(account)
    @account = account
    # Sanity check:
    raise unless @account.onboarding_stage == "spending"

    @main_passenger = @account.main_passenger
    @main_info      = @main_passenger.build_spending_info

    @has_companion  = @account.has_companion?

    self.companion_info_personal_spending = 0

    if @account.has_companion?
      raise if @account.companion.spending_info.try(:persisted?)
      @companion      = account.companion
      @companion_info = @companion.build_spending_info
    else
      # Another sanity check: you can't share expenses if you don't have a
      # companion
      raise if @account.shares_expenses?
    end
  end

  # ----- ATTRIBUTES -----

  attr_reader :main_info, :companion_info

  delegate :has_business?, to: :main_info,      prefix: true
  delegate :has_business?, to: :companion_info, prefix: true, allow_nil: true
  alias_method :main_passenger_has_business?, :main_info_has_business?
  alias_method :companion_has_business?,      :companion_info_has_business?

  attr_accessor :shared_spending

  def account_shares_expenses?
    @account.shares_expenses
  end

  def main_passenger_first_name
    @main_passenger.first_name
  end

  def companion_first_name
    @companion.first_name
  end

  SPENDING_INFO_ATTRS = %i[
    business_spending
    credit_score
    has_business
    personal_spending
    will_apply_for_loan
  ]

  %i[main_info companion_info].each do |info|
    SPENDING_INFO_ATTRS.each do |attr|
      attr_accessor :"#{info}_#{attr}"
    end
  end

  # An empty checkbox in Rails submits "0", while a radio button with
  # value 'false' submits "false" (a string, not a bool) - both of which Ruby
  # will treat as truthy - so sanitize boolean setters:
  #
  # TODO this a semi-duplicate of PassengerSurvey#has_companion= - is
  # there any way this can be DRYed e.g. converted into a class method
  # on Form?
  def main_info_will_apply_for_loan=(bool)
    @main_info_will_apply_for_loan = %w[false 0].include?(bool) ? false : !!bool
  end

  def companion_info_will_apply_for_loan=(bool)
    @companion_info_will_apply_for_loan = \
      %w[false 0].include?(bool) ? false : !!bool
  end

  def has_companion?
    @account.has_companion?
  end

  def assign_attributes(attributes)
    attributes.each { |key, value| self.send "#{key}=", value }
  end

  def save
    super do
      SPENDING_INFO_ATTRS.each do |attr|
        main_info.send("#{attr}=",      self.send("main_info_#{attr}"))
        if has_companion?
          companion_info.send("#{attr}=", self.send("companion_info_#{attr}"))
        end
      end

      if has_companion? && account_shares_expenses?
        # To eliminate the need for an extra DB column that will be null
        # most of the time: when spending is shared, it's stored internally
        # under main_passenger.personal_spending, and
        # companion.personal_spending is left blank.
        main_info.personal_spending      = self.shared_spending
        # Except we have to make it 0, not nil, because the DB column isn't
        # nullable :(
        companion_info.personal_spending = 0
      end

      @account.onboarding_stage = "main_passenger_cards"
      @account.save!(validate: false)
      main_info.save!(validate: false)
      companion_info.save!(validate: false) if has_companion?
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

  validates :main_info_credit_score,
    CREDIT_SCORE_VALIDATIONS.merge(presence: true)
  validates :main_info_personal_spending, {
    numericality: SPENDING_NUMERICALITY_VALIDATIONS.merge(
      unless: "has_companion? && account_shares_expenses?"
    ),
    presence: { unless: "has_companion? && account_shares_expenses?" }
  }

  with_options if: :main_passenger_has_business? do |survey|
    survey.validates :main_info_business_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
    }
  end

  with_options if: :has_companion? do |survey|
    survey.validates :companion_info_credit_score,
      CREDIT_SCORE_VALIDATIONS.merge(presence: true)

    survey.validates :companion_info_personal_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: { if: "has_companion? && !account_shares_expenses?" }
    }
  end

  with_options if: "has_companion? && companion_has_business?" do |survey|
    survey.validates :companion_info_business_spending, {
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
    }
  end

  with_options if: :account_shares_expenses? do
    validates :shared_spending,
      numericality: SPENDING_NUMERICALITY_VALIDATIONS,
      presence: true
  end

end
