require 'dry-types'

# A (coercible) string that strips any trailing whitespace. Not sure if this
# is the best way to do this? See github.com/dry-rb/dry-validations#213.
#
# To use: `Types::Stripped::String`. Note that trying to register the type with
# the name `Types::String::Stripped` (which imo is better) causes an error
# further down the line when you call `include Dry::Types.module`. Possible bug
# in dry types?
#
# This needs to go in an initializer because it will blow up if run more
# than once (e.g. by Rails's autoloader)
Dry::Types.register(
  'stripped.string',
  Dry::Types['string'].constructor { |*args| String(*args).strip },
)

module Types
  include Dry::Types.module
end
