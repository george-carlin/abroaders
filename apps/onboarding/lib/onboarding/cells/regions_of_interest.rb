module Onboarding
  module Cells
    module RegionsOfInterest
      # Hack to prevent annoying autoload error. See Rails issue #14844
      autoload :Survey, 'onboarding/cells/regions_of_interest/survey'
    end
  end
end
