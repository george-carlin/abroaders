module StaticPages
  module Cell
    # @!method self.call(account, options = {})
    #   @param account [Account] the currently logged-in account, if there is one.
    class ContactUs < Abroaders::Cell::Base
      include Escaped

      property :owner_first_name

      private

      def hey
        if model.nil?
          'Hey there'
        else
          "Hey, #{owner_first_name}"
        end
      end
    end
  end
end
