module AdminArea
  module Accounts
    module Cell
      class SearchForm < Abroaders::Cell::Base
        def show
          form_tag(
            search_admin_accounts_path,
            class: HTML_CLASSES,
            id:    HTML_ID,
            role: 'search',
            method: :get,
          ) do
            content_tag :div, class: 'form-group' do
              text_field(
                :accounts,
                :search,
                class: 'form-control',
                placeholder: 'Search user accounts...',
              )
            end
          end
        end

        HTML_ID      = 'admin_accounts_search_bar'.freeze
        HTML_CLASSES = 'navbar-form-custom'.freeze
      end
    end
  end
end
