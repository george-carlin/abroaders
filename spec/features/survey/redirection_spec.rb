require "rails_helper"

describe "as a new user who" do
  subject { page }

  let(:account) { create(:account, onboarding_stage: onboarding_stage) }
  before do
    # Create the bullshit needed for the pages to load okay after redirect:
    unless onboarding_stage == "passengers"
      create(:main_passenger, account: account)
    end
    if /companion/ =~ onboarding_stage
      create(:companion, account: account)
    end

    account.reload
    login_as(account)
  end

  let(:paths) do
    # A sample of paths within the app, including survey paths
    [
      card_accounts_path,
      new_travel_plan_path,
      survey_balances_path(:main),
      survey_balances_path(:companion),
      survey_card_accounts_path(:main),
      survey_card_accounts_path(:companion),
      survey_passengers_path,
      survey_readiness_path,
      survey_spending_path,
      survey_travel_plan_path,
      travel_plans_path,
      #root_path,
    ]
  end

  shared_examples "no cards or travel plans links" do
    specify "navbar does not contain links to 'Cards' or 'Travel Plans'" do
      visit survey_path
      within "#main_navbar" do
        is_expected.to have_no_link "Cards"
        is_expected.to have_no_link "Travel Plans"
      end
    end
  end

  shared_examples "redirects" do |description|
    describe "any authenticated page except #{description}" do
      it "redirects me to #{description}" do
        (paths - [survey_path]).each do |path|
          visit path
          expect(current_path).to eq survey_path
        end
      end
    end
  end

  context "who has not completed any part of the survey" do
    let(:onboarding_stage) { "travel_plans" }
    let(:survey_path) { survey_travel_plan_path }
    include_examples "redirects", "the travel plan survey"
    include_examples "no cards or travel plans links"
  end

  context "who has added travel plans" do
    let(:onboarding_stage) { "passengers" }
    let(:survey_path) { survey_passengers_path }
    include_examples "redirects", "the passengers survey"
    include_examples "no cards or travel plans links"
  end

  context "who has added travel plans and passengers" do
    let(:onboarding_stage) { "spending" }
    let(:survey_path) { survey_spending_path }
    include_examples "redirects", "the spending survey"
    #include_examples "no cards or travel plans links"
  end

  context "who needs to add the main passenger's cards" do
    let(:onboarding_stage) { "main_passenger_cards" }
    let(:survey_path) { survey_card_accounts_path(:main) }
    include_examples "redirects", "the main passenger cards survey"
    include_examples "no cards or travel plans links"
  end

  context "who needs to add the companion passenger's cards" do
    let(:onboarding_stage) { "companion_cards" }
    let(:survey_path) { survey_card_accounts_path(:companion) }
    include_examples "redirects", "the companion cards survey"
    include_examples "no cards or travel plans links"
  end

  context "who needs to add the main passenger's balances" do
    let(:onboarding_stage) { "main_passenger_balances" }
    let(:survey_path) { survey_balances_path(:main) }
    include_examples "redirects", "the main passenger balances survey"
    include_examples "no cards or travel plans links"
  end

  context "who needs to add the companion passenger's balances" do
    let(:onboarding_stage) { "companion_balances" }
    let(:survey_path) { survey_balances_path(:companion) }
    include_examples "redirects", "the companion balances survey"
    include_examples "no cards or travel plans links"
  end

  context "has added travel plan, passenger, spending, card, & balance info" do
    let(:onboarding_stage) { "readiness" }
    let(:survey_path) { survey_readiness_path }
    include_examples "redirects", "the readiness survey"
    include_examples "no cards or travel plans links"
  end
end
