require 'dry-struct'

require 'types'

class Business < Dry::Struct
  attribute :spending_usd, Types::Strict::Int.constrained(gteq: 0)
  attribute :ein, Types::Strict::Bool

  # @param spending_info [SpendingInfo]
  def self.build(spending_info)
    has_business = spending_info.has_business
    return nil if has_business == 'no_business'
    new(spending_usd: spending_info.business_spending_usd, ein: has_business == 'with_ein')
  end
end
