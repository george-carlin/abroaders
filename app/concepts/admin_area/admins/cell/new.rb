module AdminArea::Admins
  module Cell
    class New < Abroaders::Cell::Base
      option :form

      def title
        'New Admin'
      end

      subclasses_use_parent_view!

      private

      def errors
        cell(Abroaders::Cell::ValidationErrorsAlert, form)
      end

      def link_to_add_new
        link_to 'Create new admin', new_admin_admin_path
      end
    end
  end
end
