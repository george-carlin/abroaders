require "rails_helper"

describe OnboardingSurvey do
  include Rails.application.routes.url_helpers

  let(:account)   { create(:account) }
  let(:owner)     { account.owner }
  let(:companion) { account.companion }

  def survey
    described_class.new(account: account)
  end

  example "non-person specific pages" do
    expect(survey.current_page.path).to eq survey_home_airports_path
    expect(survey).not_to be_complete

    onboard_home_airports!
    expect(survey.current_page.path).to eq new_travel_plan_path
    expect(survey).not_to be_complete

    onboard_travel_plans!
    expect(survey.current_page.path).to eq type_account_path
    expect(survey).not_to be_complete
  end

  example "account with one ineligible person" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    onboard_eligibility!(account.owner, false)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey.current_page).to be_nil
    expect(survey).to be_complete
  end

  example "account with one eligible person" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    onboard_eligibility!(account.owner, true)
    expect(survey.current_page.path).to eq new_person_spending_info_path(account.owner)
    expect(survey).not_to be_complete

    onboard_spending!(account.owner)
    expect(survey.current_page.path).to eq survey_person_card_accounts_path(account.owner)
    expect(survey).not_to be_complete

    onboard_cards!(account.owner)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey).to be_complete
  end

  example "account with two ineligible people" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    create_companion!
    onboard_eligibility!(account.owner, false)
    onboard_eligibility!(account.companion, false)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.companion)
    expect(survey).not_to be_complete

    onboard_balances!(account.companion)
    expect(survey.current_page).to be_nil
    expect(survey).to be_complete
  end

  example "account with two eligible people" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    onboard_eligibility!(account.owner, true)
    create_companion!
    onboard_eligibility!(account.companion, true)

    expect(survey.current_page.path).to eq new_person_spending_info_path(account.owner)
    expect(survey).not_to be_complete

    onboard_spending!(account.owner)
    expect(survey.current_page.path).to eq survey_person_card_accounts_path(account.owner)
    expect(survey).not_to be_complete

    onboard_cards!(account.owner)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey.current_page.path).to eq new_person_spending_info_path(account.companion)
    expect(survey).not_to be_complete

    onboard_spending!(account.companion)
    expect(survey.current_page.path).to eq survey_person_card_accounts_path(account.companion)
    expect(survey).not_to be_complete

    onboard_cards!(account.companion)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.companion)
    expect(survey).not_to be_complete

    onboard_balances!(account.companion)
    expect(survey.current_page).to be_nil
    expect(survey).to be_complete
  end

  example "account with eligible owner, ineligible companion" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    onboard_eligibility!(account.owner, true)
    create_companion!
    onboard_eligibility!(account.companion, false)
    expect(survey.current_page.path).to eq new_person_spending_info_path(account.owner)
    expect(survey).not_to be_complete

    onboard_spending!(account.owner)
    expect(survey.current_page.path).to eq survey_person_card_accounts_path(account.owner)
    expect(survey).not_to be_complete

    onboard_cards!(account.owner)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.companion)
    expect(survey).not_to be_complete

    onboard_balances!(account.companion)
    expect(survey.current_page).to be_nil
    expect(survey).to be_complete
  end

  example "account with ineligible owner, eligible companion" do
    onboard_home_airports!
    onboard_travel_plans!
    onboard_type!
    onboard_eligibility!(account.owner, false)
    create_companion!
    onboard_eligibility!(account.companion, true)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.owner)
    expect(survey).not_to be_complete

    onboard_balances!(account.owner)
    expect(survey.current_page.path).to eq new_person_spending_info_path(account.companion)
    expect(survey).not_to be_complete

    onboard_spending!(account.companion)
    expect(survey.current_page.path).to eq survey_person_card_accounts_path(account.companion)
    expect(survey).not_to be_complete

    onboard_cards!(account.companion)
    expect(survey.current_page.path).to eq survey_person_balances_path(account.companion)
    expect(survey).not_to be_complete

    onboard_balances!(account.companion)
    expect(survey.current_page).to be_nil
    expect(survey).to be_complete
  end

  def create_companion!
    account.create_companion!(first_name: "A")
  end

  def onboard_home_airports!
    account.onboarded_home_airports = true
  end

  def onboard_travel_plans!
    account.onboarded_travel_plans = true
  end

  def onboard_type!
    account.onboarded_type = true
  end

  def onboard_eligibility!(person, eligible)
    person.eligible = eligible
  end

  def onboard_spending!(person)
    allow(person).to receive(:onboarded_spending?).and_return(true)
  end

  def onboard_balances!(person)
    person.onboarded_balances = true
  end

  def onboard_cards!(person)
    person.onboarded_cards = true
  end
end
