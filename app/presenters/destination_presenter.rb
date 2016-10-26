class DestinationPresenter < ApplicationPresenter
  def html_class
    # we're using dom_id, but outputting it as the html class, not the html
    # id, because different travel plans might use the same destinations (so
    # the destination IDs won't be unique)
    h.dom_id(self)
  end

  def name
    # new travel plan destinations are always airports; legacy data uses countries
    if airport?
      "#{city.name} (#{code})"
    else
      super
    end
  end

  def region_name
    region.name
  end
end
