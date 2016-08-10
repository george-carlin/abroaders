# A representation of the "onboarding survey" - the series of forms that a user
# must fill in when they first sign up to the app. The 'pages' method
# returns a list of all possible pages in the survey, in the order that a user
# should visit them.
#
# Call `current_account#onboarding_survey` to get the onboarding survey info
# for the currently logged-in user. This instance will be used to:
#
#   1. Determine whether or not the user has completed the survey.
#   2. If they haven't completed the survey, figure out which page they need
#      be redirected to.
#
# Note that not all users will have to fill in all pages of the survey; their
# answers to questions on earlier pages will determine if they need to fill in
# later pages. (E.g. users who don't add a companion won't have to fill in any
# of the forms related to their companion, and users who are ineligible to
# apply for cards don't need to fill in the 'spending info' or 'cards' pages.)
# If the user doesn't need to fill in a particular page, then Page#required?
# will return false. If the user has already completed a particular page, then
# Page#complete? will return true.
#
# The `pages` method should be the central, canonical representation of all
# pages in the onboarding survey (note: the structure of the onboarding survey,
# in terms of the business requirements, has changed multiple times in the past
# and is likely to change again in future).
class OnboardingSurvey
  include Rails.application.routes.url_helpers
  include Virtus.model

  attribute :account, Account

  delegate :owner, :companion, :has_companion?, to: :account

  def pages
    raise "account must be present" unless account.present?

    @pages ||= begin
      pages = [
        { # travel plans
          path: new_travel_plan_path,
          required: true,
          complete: account.onboarded_travel_plans?
        },

        { # account type and eligibility
          path: type_account_path,
          required: true,
          complete: account.onboarded_type?,
        },
      ]

      pages.concat(pages_for_person(owner))
      pages.concat(pages_for_person(companion)) if has_companion?

      pages.map { |page| Page.new(page) }
    end
  end

  # Returns true iff the user has fully completed the onboarding survey
  def complete?
    pages.all? { |page| !page.required? || page.complete? }
  end

  # If onboarding survey is complete, returns nil. Else returns the next Page
  # that the user must complete
  def next_page
    pages.find { |p| p.required? && !p.complete? }
  end

  class Page
    include Virtus.model

    attribute :complete, Boolean
    attribute :path,     String
    attribute :required, Boolean
  end

  private

  def pages_for_person(person)
    [
      { # spending info
        path: new_person_spending_info_path(person),
        required: person.eligible?,
        complete: person.onboarded_spending?,
      },

      { # cards
        path: survey_person_card_accounts_path(person),
        required: person.eligible?,
        complete: person.onboarded_cards?,
      },

      { # balances
        path: survey_person_balances_path(person),
        required: true,
        complete: person.onboarded_balances?,
      },
    
      { # readiness
        path: new_person_readiness_status_path(person),
        required: person.eligible?,
        complete: person.onboarded_readiness?
      },
    ]
  end

end
