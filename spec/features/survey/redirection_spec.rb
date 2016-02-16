require "rails_helper"

describe "as a new user" do
  subject { page }

  include_context "logged in as new user"

  before do
    if completed_main_survey
      create(
        :survey,
        :user => user,
        :has_added_cards    => completed_card_accounts_survey,
        :has_added_balances => completed_balances_survey
      )
      user.reload
    end
  end

  let(:paths) do
    # A sample of paths within the app, including survey paths
    [
      card_accounts_path,
      new_travel_plan_path,
      survey_balances_path,
      survey_card_accounts_path,
      survey_path,
      travel_plans_path
    ]
  end

  let(:paths_to_test) { paths - allowed_paths }

  let(:completed_main_survey)     { false }
  let(:completed_card_accounts_survey) { false }
  let(:completed_balances_survey)      { false }

  shared_examples "no cards or travel plans links" do
    it "does not contain links to 'Cards' or 'Travel Plans'" do
      visit allowed_paths.first
      within "#main_navbar" do
        is_expected.not_to have_link "Cards"
        is_expected.not_to have_link "Travel Plans"
      end
    end
  end

  context "who has not completed any part of the survey" do
    let(:allowed_paths) { [survey_path] }

    describe "any authenticated page except the main survey" do
      it "redirects me to the user info survey" do
        paths_to_test.each do |path|
          visit path
          expect(current_path).to eq survey_path
        end
      end
    end

    include_examples "no cards or travel plans links"
  end

  context "who has not completed the card accounts survey" do
    let(:completed_main_survey) { true }
    let(:allowed_paths) { [survey_card_accounts_path] }

    describe "any authenticated page except the card accounts survey" do
      it "redirects me to the card accounts survey" do
        paths_to_test.each do |path|
          visit path
          expect(current_path).to eq survey_card_accounts_path
        end
      end
    end

    include_examples "no cards or travel plans links"
  end

  context "who has not completed the balances survey" do
    let(:completed_main_survey) { true }
    let(:completed_card_accounts_survey) { true }
    let(:allowed_paths) { [survey_balances_path] }

    describe "any authenticated page except the balances survey" do
      it "redirects me to the balances survey" do
        paths_to_test.each do |path|
          visit path
          expect(current_path).to eq survey_balances_path
        end
      end
    end

    include_examples "no cards or travel plans links"
  end

  context "who has completed the balances survey" do
    let(:completed_main_survey) { true }
    let(:completed_card_accounts_survey) { true }
    let(:completed_balances_survey) { true }

    describe "trying to visit the balances survey again" do
      it "redirects me to the root" do
        visit survey_balances_path
        expect(current_path).to eq root_path
      end
    end
  end
end
