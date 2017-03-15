class Country < Destination
  def region
    Region.find_by_code(region_code)
  end

  def region=(region)
    self.region_code = region.code
  end
end
