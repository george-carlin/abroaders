require 'inflecto'

module Abroaders
  module Util
    # Takes a Hash and returns a copy with the same keys but underscored
    #
    # Abroaders::Util.underscore_keys('firstName' => 'George')
    # #=> { 'first_name' => 'George' }
    #
    # The result will have string keys, even if the input hash has symbol keys:
    #
    # Abroaders::Util.underscore_keys(firstName: 'George')
    # #=> { 'first_name' => 'George' }
    #
    # @param hash [Hash]
    # @param recursive [Boolean] (false) whether to recursively alter the keys
    #   of nested hashes too
    def self.underscore_keys(hash, recursive = nil)
      hash.each_with_object({}) do |(key, value), h|
        new_key = Inflecto.underscore(key)
        h[new_key] = case value
                     when Hash
                       recursive ? underscore_keys(value, true) : value.dup
                     when Array
                       value.map { |el| recursive ? underscore_keys(el, true) : el.dup }
                     else
                       value
                     end
      end
    end
  end
end
