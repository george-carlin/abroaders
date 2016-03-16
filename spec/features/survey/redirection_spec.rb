require "rails_helper"

describe "as a new user who has" do
  subject { page }

  before do
    account = create(:account)

    if has_added_passengers
      create(
        "main_passenger#{"_with_spending"if has_added_spending_info}",
        account: account,
        has_added_cards:    main_passenger_has_added_cards,
        has_added_balances: main_passenger_has_added_balances,
      )

      # Whether or not the account has a travel companion is irrelevant in the
      # context of this spec, *unless* we're testing the redirection to the
      # card accounts and balances surveys
      if has_companion
        create(
          :companion_with_spending,
          account: account,
          has_added_cards:    companion_has_added_cards,
          has_added_balances: companion_has_added_balances
        )
      end
    end
    account.reload
    login_as account, scope: :account
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
      survey_spending_path,
      travel_plans_path
    ]
  end

  let(:companion_has_added_balances)      { false }
  let(:companion_has_added_cards)         { false }
  let(:has_added_passengers)              { false }
  let(:has_added_spending_info)           { false }
  let(:has_companion)                     { false }
  let(:main_passenger_has_added_balances) { false }
  let(:main_passenger_has_added_cards)    { false }

  shared_examples "no cards or travel plans links" do
    specify "navbar does not contain links to 'Cards' or 'Travel Plans'" do
      visit root_path
      within "#main_navbar" do
        is_expected.not_to have_link "Cards"
        is_expected.not_to have_link "Travel Plans"
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

  context "not completed any part of the survey" do
    let(:survey_path) { survey_passengers_path }
    include_examples "redirects", "the passengers survey"
    include_examples "no cards or travel plans links"
  end

  context "added passenger but not spending info" do
    let(:has_added_passengers) { true }
    let(:survey_path) { survey_spending_path }
    include_examples "redirects", "the spending survey"
    include_examples "no cards or travel plans links"
  end

  context "added passenger and spending info but not cards" do
    let(:has_added_passengers) { true }
    let(:has_added_spending_info) { true }

    context "when the account has no travel companion" do
      let(:survey_path) { survey_card_accounts_path(:main) }
      include_examples "redirects", "the main passenger card account survey"
      include_examples "no cards or travel plans links"
    end

    context "when the account has a travel companion" do
      let(:has_companion) { true }

      context "and I have not added anyone's cards" do
        let(:survey_path) { survey_card_accounts_path(:main) }
        include_examples "redirects", "the main passenger cards survey"
        include_examples "no cards or travel plans links"
      end

      context "and I have added my cards but not my companion's" do
        let(:main_passenger_has_added_cards) { true }
        let(:companion_has_added_cards) { false }
        let(:survey_path) { survey_card_accounts_path(:companion) }
        include_examples "redirects", "the companion cards survey"
        include_examples "no cards or travel plans links"
      end
    end
  end

  context "added passenger, spending, & card info but not balances" do
    let(:has_added_passengers)           { true }
    let(:has_added_spending_info)        { true }
    let(:main_passenger_has_added_cards) { true }
    let(:companion_has_added_cards)      { true }

    context "when the account has no travel companion" do
      let(:has_companion) { false }
      let(:survey_path) { survey_balances_path(:main) }
      include_examples "redirects", "the main passenger balances survey"
      # include_examples "no cards or travel plans links"
    end

    context "when the account has a travel companion" do
      let(:has_companion) { true }

      context "and I have not added anyone's balances" do
        let(:survey_path) { survey_balances_path(:main) }
        include_examples "redirects", "the main passenger balances survey"
        include_examples "no cards or travel plans links"
      end

      context "and I have added my balances but not my companion's" do
        let(:main_passenger_has_added_balances) { true }
        let(:survey_path) { survey_balances_path(:companion) }
        include_examples "redirects", "the companion balances survey"
        include_examples "no cards or travel plans links"
      end
    end
  end

  context "added passenger, spending, card, & balance info" do
    let(:has_added_passengers)              { true }
    let(:has_added_spending_info)           { true }
    let(:main_passenger_has_added_cards)    { true }
    let(:main_passenger_has_added_balances) { true }
    it "redirects to the next stage of the survey"
  end
end
