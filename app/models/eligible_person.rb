require 'types'

# Wrapper around an eligible person with a spending info.
#
# The only time a person can be eligible with no spending info is if they're
# halfway through the onboarding survey. In which case don't use this class.
class EligiblePerson < Dry::Struct
  # Eventually if we start using these Struct objects more heavily we'll want
  # to extract hideous methods like the one below to some kind of 'mapper'
  # class. Maybe use rom-rb? Is it possible to use rom-mapper without rom's
  # persistence layer?
  def self.build(person)
    return person if person.class == self
    raise 'person must be eligible' unless person.eligible?
    spending_info = person.spending_info
    raise 'person must have spending info' unless spending_info
    business = Business.build(spending_info)
    new(
      id: person.id,
      business: business,
      business_type: spending_info.has_business,
      credit_score: spending_info.credit_score,
      eligible: person.eligible,
      first_name: person.first_name,
      has_partner: person.has_partner?,
      personal_spending_usd: person.account.monthly_spending_usd,
      spending_info_id: spending_info.id,
      will_apply_for_loan: spending_info.will_apply_for_loan,
    )
  end

  attribute :id, Types::Strict::Int
  attribute :spending_info_id, Types::Strict::Int

  attribute :business, Business.optional
  attribute :business_type, SpendingInfo::BusinessType
  attribute :credit_score, SpendingInfo::CreditScore
  attribute :eligible, Types::Strict::Bool
  attribute :first_name, Types::Strict::String
  attribute :has_partner, Types::Strict::Bool
  attribute :personal_spending_usd, Types::Strict::Int
  attribute :will_apply_for_loan, Types::Strict::Bool

  alias has_partner? has_partner

  def business?
    !business.nil?
  end

  def business_has_ein?
    business.ein?
  end

  def business_spending_usd
    business.spending_usd
  end
end
