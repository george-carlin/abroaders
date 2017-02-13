class PhoneNumber < ApplicationRecord
  # I'm not sure if this kind of thing should be considered an 'operation' and
  # live under PhoneNumber::Operation, or if we should save that concept for
  # Trailblazer operations that are invoked directly from a controller action.
  # Think about it. TODO
  class Normalize
    def self.call(string)
      string.gsub(/\D/, '')
    end
  end
end
