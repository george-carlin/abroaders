module AdminArea::CardAccounts
  module Cell
    # @!method self.call(model, options = {})
    #   @option options [Reform::Form] form
    class Edit < Abroaders::Cell::Base
      include Escaped

      subclasses_use_parent_view!

      property :person

      option :form

      def title
        "Edit #{person_first_name}'s Card"
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def form_tag(&block)
        form_for form, url: form_url, &block
      end

      def form_url
        admin_card_account_path(form.model)
      end

      def person_first_name
        escape!(person.first_name)
      end
    end
  end
end
