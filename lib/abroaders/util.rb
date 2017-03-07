require 'inflecto'

module Abroaders
  module Util
    # Takes a Hash and returns a copy with the same keys but underscored
    #
    # Abroaders::Util.underscore_keys(firstName: 'George')
    # #=> { first_name: => 'George' }
    #
    # Works with string or symbol keys
    def self.underscore_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[Inflecto.underscore(k)] = v }
    end
  end
end
