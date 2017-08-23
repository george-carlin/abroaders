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

      def link_to_skip
        link_to(
          'Skip',
          skip_phone_number_path,
          class: 'btn skip-survey-btn btn-lg',
          data: { method: :post },
        )
      end
    end
  end
end
