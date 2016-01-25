require "rails_helper"

describe "card account pages spec" do
  subject { page }

  include_context "logged in"

  context "index page" do
    before do
      extra_setup
      visit card_accounts_path
    end

    let(:extra_setup) { nil }

    context "when I have not been recommended a card yet" do
      skip
    end



    context "when I have been recommended some cards" do
      let(:extra_setup) do
        @recommendations = create_list(:card_rec, 2, user: user)
      end

      it "lists them all" do
        @recommendations.each do |recommendation|
          is_expected.to have_card_account(recommendation)
          within card_account_selector(recommendation) do
            is_expected.to have_content recommendation.card_name
            is_expected.to have_content recommendation.card_bank_name
          end
        end
      end

      it "has a button to decline each recommendation" do
        @recommendations.each do |recommendation|
          is_expected.to have_selector decline_rec_btn(recommendation)
        end
      end

      it "has a button to say that I have accepted and applied" do
        pending
        @recommendations.each do |recommendation|
          is_expected.to have_selector called_bank_btn(recommendation)
        end
      end

      describe "clicking the 'decline' button" do
        let(:rec) { @recommendations[0] }
        before { find(decline_rec_btn(rec)).click }

        it "updates the account's status to 'declined'" do
          expect(rec.reload).to be_declined
        end

        it "hides the 'decline' button" do
          expect(current_path).to eq card_accounts_path
          is_expected.not_to have_selector decline_rec_btn(rec)
        end

        it "hides the 'called bank' button" do
          skip
          expect(current_path).to eq card_accounts_path
          is_expected.not_to have_selector called_bank_btn(rec)
        end
      end

      describe "clicking the 'I called' button", js: true do
        let(:rec) { @recommendations[0] }
        before { find(decline_rec_btn(rec)).click }

        before { pending }

        # it "updates the account's status to 'declined'" do
        #   expect(rec.reload).to be_declined
        # end

        # it "hides the accept/decline buttons" do
        #   expect(current_path).to eq card_accounts_path
        #   is_expected.not_to have_selector decline_rec_btn(rec)
        #   is_expected.not_to have_selector called_bank_btn(rec)
        # end

        # it "hides the 'called bank' button" do
        #   pending
        #   expect(current_path).to eq card_accounts_path
        #   is_expected.not_to have_selector called_bank_btn(rec)
        # end
      end
    end

    context "when there is a recommendation that I have declined" do
      let(:extra_setup) do
        @account = create(:declined_card_recommendation, user: user)
      end

      it "displays information about it" do
        is_expected.to have_card_account(@account)
        within card_account_selector(@account) do
          is_expected.to have_content \
            "You indicated on #{@account.declined_at.strftime("%D")} "\
            "that you do not wish to apply for this card."
        end
      end

      it "doesn't have a 'decline' button" do
        within card_account_selector(@account) do
          is_expected.not_to have_selector decline_rec_btn(@account)
        end
      end
    end

    def card_account_selector(account)
      "##{dom_id(account)}"
    end

    def have_card_account(account)
      have_selector card_account_selector(account)
    end

    def decline_rec_btn(recommendation)
      "##{dom_id(recommendation, :decline)}"
    end

    def called_bank_btn(recommendation)
      "#TODO"
    end
  end
end
