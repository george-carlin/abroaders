class Account < Account.superclass
  module Cell
    # result keys:
    #   account: the currently logged-in account
    #   people:  the account's people
    #   travel_plans: the account's travel plans
    #   unresolved_recommendations: unresolved recommendations belonging to
    #       either person. Used to determine whether the 'unresolved recs'
    #       modal should be shown
    #
    # options:
    #   recommendation_timeout: the value of the 'recommendation_timeout' cookie.
    #     If it's present, hide the 'new recs' modal when it would otherwise be
    #     shown. How this works is that when a user first receives new
    #     recs they'll see the modal when they visit this page, and they
    #     have no choice but to click 'continue' and go to /cards. But
    #     when they visit /cards it will set the 'recommendation_timeout' cookie,
    #     which prevents the modal from being shown again until the cookie
    #     expires after 24 hours
    class Dashboard < Abroaders::Cell::Base
      alias result model

      private

      def account
        result['account']
      end

      def people
        content_tag :div, class: 'row' do
          cell self.class::Person, collection: result['people']
        end
      end

      def travel_plans
        cell(TravelPlans, result['travel_plans'])
      end

      def unresolved_recs_modal
        if result['unresolved_recommendations'].any? && options[:recommendation_timeout].nil?
          cell(UnresolvedRecsModal)
        else
          ''
        end
      end

      # model: a Person
      class Person < Abroaders::Cell::Base
        include Escaped

        property :id
        property :first_name
        property :eligible?

        private

        def balances
          if model.balances.any?
            balances = cell(Balance::Cell::List, model.balances.includes(:currency))
            "<h4>Balances</h4> #{balances}"
          else
            '<p>No existing frequent flyer balances</p>'
          end
        end

        def link_to_edit_spending
          link_to 'Edit', edit_person_spending_info_path(model)
        end

        def spending_info
          cell(SpendingInfo::Cell::Table, model.spending_info)
        end
      end

      # model: a collection of TravelPlans
      class TravelPlans < Abroaders::Cell::Base
        alias collection model

        private

        def any_travel_plans?
          collection.any?
        end

        def link_to_add_new
          content_tag :small do
            link_to 'Add new', new_travel_plan_path
          end
        end

        def travel_plans
          content_tag :div, class: 'account_travel_plans' do
            cell TravelPlan::Cell::Summary, collection: collection
          end
        end
      end

      # a modal that appears if the user has new recommendations that require
      # attention.
      #
      # model: a collection of unresolved recommendations (may be empty)
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
