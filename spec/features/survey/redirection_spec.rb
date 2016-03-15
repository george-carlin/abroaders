require "rails_helper"

describe "as a new user" do
  subject { page }

  before do
    account = build(:account)

    if completed_passengers_survey
      if completed_spending_survey
        create(:passenger, :with_spending_info, account: account)
      else
        create(:passenger, account: account)
      end

      account.has_added_cards    = completed_cards_survey
      account.has_added_balances = completed_balances_survey
    end
    account.save!
    login_as account, scope: :account
  end

  let(:paths) do
    # A sample of paths within the app, including survey paths
    [
      card_accounts_path,
      new_travel_plan_path,
      survey_balances_path,
      survey_card_accounts_path,
      survey_passengers_path,
      survey_spending_path,
      travel_plans_path
    ]
  end

  let(:paths_to_test) { paths - allowed_paths }

  let(:completed_passengers_survey) { false }
  let(:completed_spending_survey)   { false }
  let(:completed_cards_survey)      { false }
  let(:completed_balances_survey)   { false }

  shared_examples "no cards or travel plans links" do
    specify "navbar does not contain links to 'Cards' or 'Travel Plans'" do
      visit allowed_paths.first
      within "#main_navbar" do
        is_expected.not_to have_link "Cards"
        is_expected.not_to have_link "Travel Plans"
      end
    end
  end

  context "who has not completed any part of the survey" do
    let(:allowed_paths) { [survey_passengers_path] }

    describe "any authenticated page except the passengers survey" do
      it "redirects me to the passengers survey" do
        paths_to_test.each do |path|
          visit path
          expect(current_path).to eq survey_passengers_path
        end
      end
    end

    include_examples "no cards or travel plans links"
  end

  context "who has completed the passengers survey" do
    let(:completed_passengers_survey) { true }

    context "but not the spending info survey" do
      let(:allowed_paths) { [survey_spending_path] }

      describe "any authenticated page except the spending survey" do
        it "redirects me to the spending survey" do
          paths_to_test.each do |path|
            visit path
            expect(current_path).to eq survey_spending_path
          end
        end
      end

      include_examples "no cards or travel plans links"
    end

    context "and the spending info survey" do
      let(:completed_spending_survey) { true }

      context "but not the card accounts survey" do
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

      context "and the card accounts survey" do
        let(:completed_cards_survey) { true }

        context "but not the balances survey" do
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

        context "and the balances survey" do
          let(:completed_balances_survey) { true }
          pending
        end
      end
    end
  end # who has completed the passengers survey

end
