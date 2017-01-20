class PhoneNumber < ApplicationRecord
  class Normalize
    def self.call(string)
      string.gsub(/\D/, '')
    end
  end
end
