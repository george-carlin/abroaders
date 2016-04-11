class SpendingSurvey < Form

  def initialize(person)
    @person = person
    # default values:
    self.citizenship         = "us_citizen"
    self.has_business        = "no_business"
    self.will_apply_for_loan = false
  end

  # ----- ATTRIBUTES -----

  attr_reader :person

  attr_accessor :business_spending_usd,
                :citizenship,
                :credit_score,
                :has_business,
                :monthly_spending_usd
  attr_boolean_accessor :will_apply_for_loan

  # Make form_for play nicely:
  def self.name
    "SpendingInfo"
  end

  def has_business?
    %w[with_ein without_ein].include?(has_business)
  end

  def save
    super do
      person.create_spending_info!(
        business_spending_usd: has_business? ? business_spending_usd : nil,
        credit_score:          credit_score,
        citizenship:           citizenship,
        has_business:          has_business,
        will_apply_for_loan:   will_apply_for_loan,
      )
      person.account.update_attributes!(
        monthly_spending_usd: monthly_spending_usd
      )
    end
  end

  # Validations

  validates :credit_score,
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: ::SpendingInfo::MINIMUM_CREDIT_SCORE,
      less_than_or_equal_to:    ::SpendingInfo::MAXIMUM_CREDIT_SCORE,
    },
    presence: true

  with_options(
    numericality: {
      # avoid duplicate error message (from presence validation) when nil:
      allow_blank: true,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
    },
    presence: true
  ) do
    validates :monthly_spending_usd
    validates :business_spending_usd, if: :has_business?
  end

end
