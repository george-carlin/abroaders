module Onboarding
  extend ActiveSupport::Concern

  def redirect_if_not_onboarded!
    return if current_account.onboarded?
    redirect_to onboarding_survey_path
  end

  def onboarding_survey_path
    case current_account.onboarding_state
    when "home_airports"       then survey_home_airports_path
    when "travel_plan"         then new_travel_plan_path
    when "regions_of_interest" then survey_interest_regions_path
    when "account_type"        then type_account_path
    when "eligibility"         then survey_eligibility_path
    when "owner_cards"         then survey_person_card_accounts_path(current_account.owner)
    when "owner_balances"      then survey_person_balances_path(current_account.owner)
    when "companion_cards"     then survey_person_card_accounts_path(current_account.companion)
    when "companion_balances"  then survey_person_balances_path(current_account.companion)
    when "spending"            then survey_spending_info_path
    when "readiness"           then survey_readiness_path
    when "phone_number"        then raise "not yet implemented"
    when "complete"            then root_path
    end
  end

  def redirect_if_onboarding_wrong_person_type!
    state = current_account.onboarding_state
    return unless state =~ /\A(owner|companion)_/ && $1 != @person.type
    redirect_to onboarding_survey_path
  end

  module ClassMethods
    def onboard(*states_and_opts)
      opts    = states_and_opts.extract_options!
      states  = states_and_opts
      actions = opts.fetch(:with)

      skip_before_action :redirect_if_not_onboarded!,       only: actions
      before_action :redirect_if_on_wrong_onboarding_page!, only: actions

      define_method :redirect_if_on_wrong_onboarding_page! do
        return if current_account.onboarded? && opts[:revisitable]
        return if states.include?(current_account.onboarding_state.to_sym)
        redirect_to onboarding_survey_path
      end
    end
  end
end
