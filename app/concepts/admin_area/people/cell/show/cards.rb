module AdminArea
  module People
    module Cell
      class Show < Show.superclass
        # @!method self.call(person, options = {})
        #   @param person [Person] make sure that card_accounts => product => bank
        #     is eager-loaded.
        class Cards < Abroaders::Cell::Base
          property :card_accounts
          property :card_recommendations

          private

          def link_to_add_new_card_account
            link_to raw('&plus; Add'), new_admin_person_card_account_path(model)
          end

          def card_accounts_table
            if card_accounts.any?
              content_tag :div, id: 'admin_person_card_accounts' do
                cell(CardAccounts::Cell::Table, card_accounts)
              end
            else
              '<p id="admin_person_card_accounts_none">User has no existing card accounts</p>'
            end
          end

          def card_recommendations_table
            # Always output the table onto the page, but hide it with CSS if
            # there are no recs. It will be shown later by JS if the admin
            # makes a rec.
            visible_recs = card_recommendations.reject { |r| r.pulled? || r.opened? }
            table = content_tag(
              :div,
              id: 'admin_person_card_recommendations',
              class: 'admin_person_card_recommendations',
              style: visible_recs.any? ? '' : 'display:none;',
            ) do
              cell(CardRecommendations::Cell::Table, visible_recs)
            end

            if visible_recs.any?
              table
            else
              "#{table} <p id='admin_person_card_recommendations_none'>User has no recs</p>"
            end
          end
        end
      end
    end
  end
end
