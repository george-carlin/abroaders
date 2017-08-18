module AdminArea::SpendingInfos
  module Cell
    # model: a SpendingInfo
    class Edit < ::SpendingInfo::Cell::Edit
      def title
        "Edit Spending for #{first_name}"
      end

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form, model_name: 'information')
      end

      def first_name
        escape!(person.first_name)
      end

      def url
        admin_person_spending_info_path(person)
      end
    end
  end
end
