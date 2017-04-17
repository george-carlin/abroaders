module AdminArea
  module Accounts
    module Cell
      class Index < Abroaders::Cell::Base
        extend Dry::Configurable

        include Kaminari::Cells

        # Expose this as a configurable setting so that we can override it
        # in tests, then the tests won't have to create 50+ accounts per example.
        setting :accounts_per_page, 50

        def title
          'Accounts'
        end

        private

        def accounts_per_page
          self.class.config.accounts_per_page
        end

        def page
          options[:page] || 1
        end

        def paginated_accounts
          @paginated_accounts ||= model.page(page).per_page(accounts_per_page)
        end

        def paginator
          paginate(paginated_accounts)
        end

        def table_rows
          cell(TableRow, collection: paginated_accounts)
        end

        # @!method self.call(account, options = {})
        class TableRow < Abroaders::Cell::Base
          include Escaped

          property :companion
          property :couples?
          property :created_at
          property :email
          property :onboarded?
          property :owner
          property :people
          property :phone_number

          private

          def onboarded_icon
            onboarded? ? raw('<i class="fa fa-check"> </i>') : ''
          end

          def tr(&block)
            content_tag_for(:tr, model, &block)
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

          def link_to_person(person)
            link_to escape(person.first_name), admin_person_path(person)
          end
        end
      end
    end
  end
end
