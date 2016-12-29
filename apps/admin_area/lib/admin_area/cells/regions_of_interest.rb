module AdminArea
  module Cells
    module RegionsOfInterest
      # Hack to prevent annoying autoload error. See Rails issue #14844
      autoload :List, 'admin_area/cells/regions_of_interest/list'
    end
  end
end
