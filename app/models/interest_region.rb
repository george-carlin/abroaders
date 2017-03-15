class InterestRegion < ApplicationRecord
  def region
    Region.find_by_code(region_code)
  end

  belongs_to :account
end
