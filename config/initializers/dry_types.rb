require 'dry-types'

# Custom type definitions need to go here because they will blow up if the
# Rails autoloader runs this file more than once (i.e. it reloads it)

# Types::Stripped::String
# A (coercible) string that strips any trailing whitespace. Not sure if this
# is the best way to do this? See github.com/dry-rb/dry-validations#213.
#
# Note that trying to register the type with the name `Types::String::Stripped`
# (which imo is better) causes an error further down the line when you call
# `include Dry::Types.module`. Possible bug in dry types?
Dry::Types.register(
  'stripped.string',
  Dry::Types['string'].constructor { |*args| String(*args).strip },
)


# Types::Form::AmericanDate
#
# When passed a date as a string, parses it in the format m/d/y, not d/m/y.
# Otherwise behaves the same as Types::Form::Date.
Dry::Types.register(
  'form.american_date',
  Dry::Types::Definition.new(Date).constructor do |date|
    if date.is_a?(String) && (date =~ Types::Form::AmericanDate.meta[:regex])
      Date.strptime(date.strip, Types::Form::AmericanDate.meta[:format])
    else
      Dry::Types['form.date'][date]
    end
  end.meta(
    regex: /\A\s*(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\/\d{4}\s*\Z/.freeze,
    format: '%m/%d/%Y'.freeze,
  )
)

module Types
  include Dry::Types.module
end
