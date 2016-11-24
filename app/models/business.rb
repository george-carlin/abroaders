# In future we may extract the 'business spending' columns from SpendingInfo
# and create a full-blown ActiveRecord model called Business. For now, just
# leave this placeholder class here as a wrapper to be used by certain Cells:
class Business
  attr_reader :spending_usd, :ein

  def self.build(spending_info)
    has_business = spending_info.has_business
    return nil if has_business == 'no_business'
    new(spending_usd: spending_info.business_spending_usd, ein: has_business == 'with_ein')
  end

  def initialize(attrs = {})
    @spending_usd = attrs[:spending_usd]
    @ein          = attrs[:ein]
  end
end
