require 'types'

# Wrapper around an eligible person with a spending info.
#
# The only time a person can be eligible with no spending info is if they're
# halfway through the onboarding survey. In which case don't use this class.
class EligiblePerson < Dry::Struct
  def self.build(person)
    return person if person.class == self
    raise 'person must be eligible' unless person.eligible?
    spending_info = person.spending_info
    raise 'person must have spending info' unless spending_info
    new(
      business_spending_usd: spending_info.business_spending_usd,
      credit_score: spending_info.credit_score,
      eligible: person.eligible,
      first_name: person.first_name,
      has_business: spending_info.has_business,
      has_partner: person.has_partner?,
      personal_spending_usd: person.account.monthly_spending_usd,
      will_apply_for_loan: spending_info.will_apply_for_loan,
      id: person.id,
      spending_info_id: spending_info.id,
    )
  end

  attribute :business_spending_usd, Types::Strict::Int.constrained(gteq: 0).optional
  attribute :credit_score, SpendingInfo::CreditScore
  attribute :eligible, Types::Strict::Bool
  attribute :first_name, Types::Strict::String
  attribute :has_business, SpendingInfo::BusinessType
  attribute :has_partner, Types::Strict::Bool
  attribute :personal_spending_usd, Types::Strict::Int
  attribute :will_apply_for_loan, Types::Strict::Bool

  attribute :id, Types::Strict::Int
  attribute :spending_info_id, Types::Strict::Int

  alias has_partner? has_partner
end
