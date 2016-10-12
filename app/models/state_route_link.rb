class StateRouteLink
  include Rails.application.routes.url_helpers
  include Virtus.model

  attribute :account, Account

  private *delegate(:owner, :companion, :has_companion?, to: :account)

  # TODO: fill missing routes as soon as we get them
  def map
    routes = {
      home_airports: {
        path: survey_home_airports_path
      },

      travel_plan: {
        path: new_travel_plan_path,
        revisitable: true
      },

      regions_of_interest: {
        path: ""
      },

      account_type: {
        path: type_account_path
      },

      eligibility: {
        path: ""
      },

      owner_cards: {
        path: survey_person_card_accounts_path(owner)
      },

      owner_balances: {
        path: survey_person_balances_path(owner)
      },

      spending: {
        path: ""
      },

      readiness: {
        path: ""
      },

      phone_number: {
        path: ""
      }
    }

    if companion
      companion_routes = {
        companion_cards: {
          path: survey_person_card_accounts_path(companion)
        },

        companion_balances: {
          path: survey_person_balances_path(companion)
        }
      }
      routes.merge!(companion_routes)
    end

    routes
  end
end
