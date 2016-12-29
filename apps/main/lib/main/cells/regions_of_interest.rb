module Main
  module Cells
    module RegionsOfInterest
      # Hack to prevent annoying autoload error. See Rails issue #14844
      autoload :Survey, 'main/cells/regions_of_interest/survey'
    end
  end
end
