module StaticPages
  module Cell
    class ContactUs < Abroaders::Cell::Base
      option :account, optional: true

      private

      def hey
        if account.nil?
          'Hey there'
        else
          name = ERB::Util.html_escape(account.owner_first_name)
          "Hey, #{name}"
        end
      end
    end
  end
end
