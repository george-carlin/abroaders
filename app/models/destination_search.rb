class DestinationSearch < Searchlight::Search

  def base_query
    Destination.all
  end

  def search_typeahead
    params = 2.times.map { "%#{typeahead}%" }
    query.where("name ILIKE ? or code ILIKE ?", *params)
  end

end
