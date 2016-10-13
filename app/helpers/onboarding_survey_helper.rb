module OnboardingSurveyHelper
  def onboarding_survey_path
    state = current_account.onboarding_state.to_sym
    onboarding_survey_routes[state]
  end

  # This will return some false positives because it only checks the path, not
  # the HTTP verb. But I don't think this matters for now.
  def current_survey_path?(path)
    onboarding_survey_path == path || onboarding_survey_submission_path.include?(path)
  end

  private

  def onboarding_survey_routes
    @onboarding_survey_routes ||= begin
      owner = current_account.owner
      routes = {
        home_airports:       survey_home_airports_path,
        travel_plan:         new_travel_plan_path,
        regions_of_interest: "TODO",
        account_type:        type_account_path,
        eligibility:         "TODO",
        owner_cards:         survey_person_card_accounts_path(owner),
        owner_balances:      survey_person_balances_path(owner),
        spending:            "TODO",
        readiness:           "TODO",
        phone_number:        "TODO",
      }

      if (companion = current_account.companion)
        routes.merge!(
          companion_cards:    survey_person_card_accounts_path(companion),
          companion_balances: survey_person_balances_path(companion),
        )
      end

      routes
    end
  end

  def onboarding_survey_submission_routes
    @onboarding_survey_submission_routes ||= begin
      owner = current_account.owner
      routes = {
        home_airports:       [survey_home_airports_path],
        travel_plan:         [travel_plans_path],
        regions_of_interest: "TODO",
        account_type:        type_account_path,
        eligibility:         "TODO",
        owner_cards:         survey_person_card_accounts_path(owner),
        owner_balances:      survey_person_balances_path(owner),
        spending:            "TODO",
        readiness:           "TODO",
        phone_number:        "TODO",
      }

      if (companion = current_account.companion)
        routes.merge!(
          companion_cards:    survey_person_card_accounts_path(companion),
          companion_balances: survey_person_balances_path(companion),
        )
      end

      routes
    end
  end

  def onboarding_survey_submission_path
    state = current_account.onboarding_state.to_sym
    onboarding_survey_submission_routes[state]
  end
end
