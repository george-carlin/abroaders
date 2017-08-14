module PhoneNumber
  class Normalize
    # Remove everything that isn't a number. This column will be used by
    # the account search function to search accounts by phone number.
    def self.call(string)
      string.gsub(/\D/, '')
    end

    class US
      # If the number looks like it might be a US phone number, then remove all
      # non-digits, and add the country code if it's not already there.
      #
      # We need it like this for interacting with APIs like Twilio. Storing it
      # in a separate DB column might not be strictly the best design, but it's
      # the best way to make it available in a Heroku dataclip that will be
      # consumed by Erik's spreadsheets.
      #
      # For simplicity's sake, a string is considered to look like a US phone
      # number if:
      #
      # - It has 10 digits, ignoring all non-digit characters.
      #
      # OR
      #
      # - It has 11 digits, ignoring all non-digit characters, and the first
      #   digit is a '1'
      #
      # If the string doesn't look like a U.S phone number, then this op will
      # return nil
      def self.call(string)
        return nil if string.nil?
        digits_only = string.gsub(/\D/, '')
        case digits_only.length
        when 10
          "1#{digits_only}"
        when 11
          digits_only[0] == '1' ? digits_only : nil
        end
      end
    end
  end
end
