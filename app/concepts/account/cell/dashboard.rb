class Account < Account.superclass
  module Cell
    # The main user dashboard, shown on the root page.
    #
    # @!method self.call(account)
    class Dashboard < Abroaders::Cell::Base
      include Escaped

      property :actionable_card_recommendations?
      property :unresolved_recommendation_requests?
      property :owner_first_name

      subclasses_use_parent_view!

      private

      def lead_text
        if model.unresolved_recommendation_requests?
          t('dashboard.account.unresolved_rec_req.title')
        elsif model.card_recommendations.any?
          "We are amped up to help you save on travel. <br/> Don't be shy to "\
          'reach out if you have any questions'
        elsif model.eligible_people.any?
          t('dashboard.account.eligible.title')
        else
          t('dashboard.account.ineligible.title')
        end
      end

      def actionable_recs_modal
        if actionable_card_recommendations? && cookies[:recommendation_timeout].nil?
          cell(ActionableRecsModal)
        else
          ''
        end
      end

      def welcome
        "Welcome to Abroaders, #{owner_first_name}."
      end

      class ActionableRecsModal < Abroaders::Cell::Base
        private

        def container(&block)
          content_tag(
            :div,
            'tabindex': '-1',
            'aria-labelledby': 'actionable_recommendations_notification_modal_label',
            'data-backdrop': 'static',
            'role': 'dialog',
            class: 'modal fade hmodal-info text-center',
            id: 'actionable_recommendations_notification_modal',
          ) do
            content_tag :div, class: 'modal-dialog' do
              content_tag :div, class: 'modal-content', &block
            end
          end
        end

        def image
          image_tag(
            'party-popper.png',
            alt: 'Ta-da',
            class: 'img img-responsive img-circle9 center text-center',
            size: '90x90',
            src: '#',
            style: 'margin: 0 auto;',
          )
        end

        def link_to_continue
          link_to 'Continue', cards_path, class: 'btn btn-lg btn-success'
        end
      end
    end
  end
end
