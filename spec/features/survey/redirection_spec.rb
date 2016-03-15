require "rails_helper"

describe "as a new user" do
  subject { page }

  before do
    account = build(:account)

    if completed_passengers_survey
      passenger = if completed_spending_survey
                    create(:passenger, :with_spending_info, account: account)
                  else
                    create(:passenger, account: account)
                  end

      # Whether or not the account has a travel companion is irrelevant in the
      # context of this spec, *unless* we're testing the redirection to the
      # card accounts survey
      if has_companion
        companion_opts = [:companion, :with_spending_info, { account: account }]
        if completed_companion_cards_survey
          companion_opts[2][:has_added_cards] = true
        end
        create(:passenger, *companion_opts)
      end

      if completed_main_cards_survey
        passenger.update_attributes!(has_added_cards: true)
      end

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
      survey_card_accounts_path(:main),
      survey_card_accounts_path(:companion),
      survey_passengers_path,
      survey_spending_path,
      travel_plans_path
    ]
  end

  let(:completed_passengers_survey)      { false }
  let(:completed_spending_survey)        { false }
  let(:completed_main_cards_survey)      { false }
  let(:completed_companion_cards_survey) { false }
  let(:completed_balances_survey)        { false }
  let(:has_companion)                    { false }

  shared_examples "no cards or travel plans links" do
    specify "navbar does not contain links to 'Cards' or 'Travel Plans'" do
      visit root_path
      within "#main_navbar" do
        is_expected.not_to have_link "Cards"
        is_expected.not_to have_link "Travel Plans"
      end
    end
  end

  def self.it_redirects_to(route_name, description)
    # the route helpers, e.g. survey_spending_path, aren't available in the
    # scope of a 'describe' block (i.e. in the scope from which
    # `it_redirects_to` will be called. So pass the method name as a string and
    # get the route using some eval hackery:
    let(:survey_path) { eval(route_name.to_s)  }

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
    it_redirects_to(:survey_passengers_path, "the passengers survey")
    include_examples "no cards or travel plans links"
  end

  context "who has completed the passengers survey" do
    let(:completed_passengers_survey) { true }

    context "but not the spending info survey" do
      it_redirects_to(:survey_spending_path, "the spending survey")
      include_examples "no cards or travel plans links"
    end

    context "and the spending info survey" do
      let(:completed_spending_survey) { true }

      context "but not the card accounts survey" do
        context "when the account has no travel companion" do
          it_redirects_to(
            "survey_card_accounts_path(:main)",
            "the main passenger card account survey"
          )

          include_examples "no cards or travel plans links"
        end

        context "when the account has a travel companion" do
          let(:has_companion) { true }

          context "and I have not added anyone's cards" do
            it_redirects_to(
              "survey_card_accounts_path(:main)",
              "the main passenger card account survey"
            )
          end

          context "and I have added my cards" do
            let(:completed_main_cards_survey) { true }

            context "but not my companion's cards" do
              let(:completed_companion_cards_survey) { false }
              it_redirects_to(
                "survey_card_accounts_path(:companion)",
                "the companion passenger card account survey"
              )
            end

            context "and my companion's cards" do
              let(:completed_companion_cards_survey) { true }
              it_redirects_to "survey_balances_path", "the balances survey"
            end
          end

          include_examples "no cards or travel plans links"
        end
      end

      context "and the card accounts survey" do
        let(:completed_main_cards_survey) { true }

        context "but not the balances survey" do
          it_redirects_to("survey_balances_path", "the balances survey")
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
