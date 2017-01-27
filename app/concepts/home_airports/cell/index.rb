module HomeAirports
  module Cell
    # model = a collection of Airports
    class Index < Trailblazer::Cell
      alias airports model
    end
  end
end
