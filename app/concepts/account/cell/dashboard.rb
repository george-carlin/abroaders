class Account < Account.superclass
  module Cell
    # @!self.call(account)
    class Dashboard < Abroaders::Cell::Base
      extend Abroaders::Cell::Result

      skill :account
      skill :unresolved_recommendations

      private

      def owner_first_name
        ERB::Util.html_escape(account.owner_first_name)
      end

      def unresolved_recs_modal
        if result['unresolved_recommendations'].any? && cookies[:recommendation_timeout].nil?
          cell(UnresolvedRecsModal)
        else
          ''
        end
      end

      class UnresolvedRecsModal < Abroaders::Cell::Base
        private

        def container(&block)
          content_tag(
            :div,
            'tabindex': '-1',
            'aria-labelledby': 'unresolved_recommendations_notification_modal_label',
            'data-backdrop': 'static',
            'role': 'dialog',
            class: 'modal fade in',
            id: 'unresolved_recommendations_notification_modal',
          ) do
            content_tag :div, class: 'modal-dialog' do
              content_tag :div, class: 'modal-content', &block
            end
          end
        end

        def link_to_continue
          link_to 'Continue', cards_path, class: 'btn btn-primary'
        end
      end
    end
  end
end
