module Main
  module Cells
    # Hack to prevent annoying autoload error. See Rails issue #14844
    autoload :RegionsOfInterest, 'main/cells/regions_of_interest'
  end
end
