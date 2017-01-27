require 'dry-types'

# Types::StrippedString
#
# A (coercible) string that strips any trailing whitespace. Not sure if this
# is the best way to do this? See github.com/dry-rb/dry-validations#213.
Dry::Types.register(
  'stripped_string',
  Dry::Types['string'].constructor { |*args| String(*args).strip },
)

# Types::BlankString
#
# Coerces the input to a string if possible, then returns '' if the string is
# blank, else returns an error. Useful in conjunction with other types, e.g. if
# you want to specify that value can be a string following a certain format
# *or* a blank string. (This is more flexible than using '.optional', because
# .optional only allows nil, not blank strings.)
#
# E.g.:
#
# property :foo, type: Types::StrippedString.constrained(
#                        format: /\A[A-Z]{5}\z/,
#                      ) | Types::BlankString.optional
#
Dry::Types.register(
  'blank_string',
  Dry::Types['stripped_string'].constrained(format: /\A\s*\z/),
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
    regex: /\A\s*(?:0?[1-9]|1[0-2])\/(?:0?[1-9]|[1-2]\d|3[01])\/\d{4}\s*\Z/,
    format: '%m/%d/%Y'.freeze,
  ),
)

module Types
  # A thought - gem dependencies might have their own module which includes
  # Dry::Types.module, and they might register their own custom types. Isn't
  # this a kind of global namespace pollution, which could result in naming
  # clashes between gems? Seems like a design flaw in dry-types... maybe open
  # an issue there
  include Dry::Types.module
end
