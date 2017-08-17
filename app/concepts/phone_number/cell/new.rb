module PhoneNumber
  module Cell
    class New < Abroaders::Cell::Base
      option :form

      def title
        'Phone Number'
      end

      private

      def errors
        messages = form.errors.messages
        return '' unless messages.any?
        content = "Error: Phone number #{messages[:phone_number].to_sentence}. "\
                  "Please click the 'Skip' button if you do not wish to add a "\
                  "phone number."
        cell(Abroaders::Cell::ErrorAlert, nil, content: content)
      end
    end
  end
end
