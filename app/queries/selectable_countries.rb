class SelectableCountries
  def self.all
    countries = Destination.country.order("name ASC").to_a

    # Move the U.S. and related 'countries' to the top of the list
    if ha = countries.detect { |c| c.name == "Hawaii" }
      countries.delete(ha)
      countries.unshift(ha)
    end

    if al = countries.detect { |c| c.name == "Alaska" }
      countries.delete(al)
      countries.unshift(al)
    end

    if us = countries.detect { |c| c.name == "United States (Continental 48)" }
      countries.delete(us)
      countries.unshift(us)
    end

    countries
  end
end
