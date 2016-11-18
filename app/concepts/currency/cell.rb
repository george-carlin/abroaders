class Currency::Cell < Trailblazer::Cell
  property :name

  # "Bank of America (Americard Points)" => "Bank of America"
  def short_name
    # FIXME really this should be the other way around: 'Bank of America'
    # and 'Americard Points' should be 
    name.sub(/\s+\(.*\)\s*/, '')
  end
end
