module DestinationsHelper

  # Returns "name (region)" if destination is not a region, else just returns
  # the region name
  def destination_name_with_region(dest)
    if dest.region?
      dest.name
    elsif dest.region.present?
      "#{dest.name} (#{dest.region.name})"
    else
      raise "no region present for #{dest.name}"
    end
  end

end
