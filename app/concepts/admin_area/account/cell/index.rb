module AdminArea
  module Account
    module Cell
      class Index < Trailblazer::Cell
        extend Dry::Configurable

        include Kaminari::Cells
        alias accounts model

        # Expose this as a configurable setting so that we can override it
        # in tests, then the tests won't have to create 50+ accounts per example.
        setting :accounts_per_page, 50

        private

        def accounts_per_page
          self.class.config.accounts_per_page
        end

        def page
          options[:page] || 1
        end

        def paginated_accounts
          @paginated_accounts ||= accounts.page(page).per_page(accounts_per_page)
        end

        def paginator
          paginate(paginated_accounts)
        end

        def table_rows
          cell(TableRow, collection: paginated_accounts)
        end

        class TableRow < Trailblazer::Cell
          include ActionView::Helpers::RecordTagHelper

          property :companion
          property :couples?
          property :created_at
          property :email
          property :onboarded?
          property :owner
          property :people

          private

          def onboarded_icon
            onboarded? ? raw('<i class="fa fa-check"> </i>') : ''
          end

          def phone_number
            model.phone_number&.number || ''
          end

          def tr(&block)
            content_tag_for(
              :tr,
              model,
              {
                'data-companion-name': companion&.first_name,
                'data-email':          email,
                'data-onboarded':      onboarded?,
                'data-owner-name':     owner.first_name,
              },
              &block
            )
          end

          def link_to_owner
            link_to_person(owner)
          end

          def link_to_companion
            couples? ? link_to_person(companion) : '-'
          end

          def created_at
            super.strftime('%D')
          end

          def last_recommendations_at
            timestamps = people.map(&:last_recommendations_at).compact
            timestamps.any? ? timestamps.max.strftime('%D') : '-'
          end

          def person_readiness_icon(person)
            ::Person::Cell::ReadinessIcon.(person).()
          end

          def link_to_person(person)
            text = "#{person.first_name} #{person_readiness_icon(person)}"
            link_to text, admin_person_path(person)
          end
        end
      end
    end
  end
end
