class SpendingInfo::Form < Reform::Form
  feature Coercion

  model :spending_info

  property :person do
    property :account do
      property :monthly_spending_usd, type: Types::Form::Int
    end

    unnest :monthly_spending_usd, from: :account
  end
  unnest :monthly_spending_usd, from: :person

  property :business_spending_usd, type: Types::Form::Int
  property :credit_score, type: Types::Form::Int
  property :has_business, type: Types::Strict::String.enum('no_business', 'with_ein', 'without_ein')
  property :will_apply_for_loan, type: Types::Form::Bool.default(false)

  def sync
    self.business_spending_usd = nil unless has_business?
    super
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
  validates :business_spending_usd,
            numericality: {
              # avoid duplicate error message (from presence validation) when nil:
              allow_blank: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: POSTGRESQL_MAX_INT_VALUE,
            },
            presence: true,
            if: :has_business?
  validates :monthly_spending_usd,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  def has_business?
    %w[with_ein without_ein].include?(has_business)
  end
end
