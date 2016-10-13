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
        { # home airports
          complete:    account.onboarded_home_airports?,
          path:        survey_home_airports_path,
          required:    true,
          revisitable: false,
          submission_paths: survey_home_airports_path,
        },

        { # travel plans
          complete:    account.onboarded_travel_plans?,
          path:        new_travel_plan_path,
          required:    true,
          revisitable: true,
          submission_paths: [travel_plans_path, skip_survey_travel_plans_path],
        },

        { # account type
          complete:    account.onboarded_type?,
          path:        type_account_path,
          required:    true,
          revisitable: false,
          submission_paths: [solo_account_path, couples_account_path],
        },

        { # eligibility
          complete:    account.onboarded_eligibility?,
          path:        survey_eligibility_path,
          required:    true,
          revisitable: false,
          submission_paths: [survey_eligibility_path],
        },

        { # spending info
          complete:    account.people.all?(&:onboarded_spending?),
          path:        new_spending_info_path,
          required:    account.people.any?(&:eligible?),
          revisitable: false,
          submission_paths: spending_info_path,
        },

      ]

      pages.concat(pages_for_person(owner))
      pages.concat(pages_for_person(companion)) if has_companion?

      pages.map { |page| Page.new(page) }
    end
  end

  # Returns true iff the user has fully completed the onboarding survey
  def complete?
    !current_page.present?
  end

  # If onboarding survey is complete, returns nil. Else returns the next Page
  # that the user must complete
  def current_page
    pages.find { |p| p.required? && !p.complete? }
  end

  # returns true if the given path can't be visited, given the current state
  # of the survey
  def redirect_from_request?(request)
    if complete?
      pages.any? { |p| p.reached_by_request?(request) && !p.revisitable? }
    else
      !current_page.reached_by_request?(request)
    end
  end

  class Page
    include Virtus.model

    attribute :complete,         Boolean
    # The path that the user must visit to *view* this page of the survey
    attribute :path,             String
    attribute :required,         Boolean
    # can this page be visited again once the onboarding survey is complete?
    attribute :revisitable,      Boolean
    # The path(s) that the user must make a request to in order to *submit*
    # this page of the survey. Note that there may be more than one per page,
    # since some survey have multiple ways to be completed.
    attribute :submission_paths, Array

    def reached_by_request?(request)
      if request.method == "GET"
        self.path == request.path
      else 
        submission_paths.include?(request.path)
      end
    end
  end

  private

  def pages_for_person(person)
    [
      { # cards
        complete:    person.onboarded_cards?,
        path:        survey_person_card_accounts_path(person),
        required:    person.eligible?,
        revisitable: false,
        submission_paths: [survey_person_card_accounts_path(person)],
      },

      { # balances
        complete:    person.onboarded_balances?,
        path:        survey_person_balances_path(person),
        required:    true,
        revisitable: false,
        submission_paths: [survey_person_balances_path(person)],
      },
    ]
  end

end
