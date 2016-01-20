require "rails_helper"

describe "admin section" do
  describe "show user page" do
    subject { page }

    include_context "logged in as admin"

    before do
      @cards = create_list(:card, 4)
      @user  = create(:user)
      extra_setup
      visit admin_user_path(@user)
    end

    let(:extra_setup) { nil }

    context "when the user" do
      context "has no existing card accounts/recommendations" do
        it "says so" do
          should have_content t("admin.users.card_accounts.none")
        end
      end
    end

    context "has already been recommended at least one card" do
      let(:extra_setup) do
        @recommended_card = @cards.first
        @rec = create(
          :card_recommendation, user: @user, card: @recommended_card
        )
      end

      it "lists existing card recommendations" do
        should have_selector card_account_selector(@rec)
        within card_account_selector(@rec) do
          is_expected.to have_content @rec.card_identifier
          is_expected.to have_content @rec.card_name
          is_expected.to have_content @rec.card_type.to_s.capitalize
          is_expected.to have_content @rec.card_brand.to_s.capitalize
          is_expected.to have_content @rec.card_type.to_s.capitalize
          is_expected.to have_content @rec.card_bank_name
        end
      end
    end

    it "has a form to recommend a new card" do
      @cards.each do |card|
        should have_selector "input#card_account_card_id_#{card.id}"
      end
    end

    it "has a dropdown to filter by bank" do
      pending
      is_expected.to have_selector "select#card_bank_filter"
      within "select#card_bank_filter" do
        is_expected.to have_text "All Banks"
        is_expected.to have_text "Barclays"
        is_expected.to have_text "Capital One"
        is_expected.to have_text "American Express"
        is_expected.to have_text "Chase"
        is_expected.to have_text "US Bank"
        is_expected.to have_text "Bank Of America"
        is_expected.to have_text "Citibank"
      end
    end

    describe "filtering cards"

    describe "selecting a card" do
      before do
        @card = @cards[2]
        choose :"card_account_card_id_#{@card.id}"
      end

      describe "and selecting 'recommend this card'" do
        before { choose :new_card_account_type_recommendation }

        describe "and clicking 'submit'" do
          let(:submit) { click_button "Submit" }

          it "assigns the card to the user in the 'recommendation' stage" do
            expect{submit}.to change{CardAccount.recommended.count}.by(1)

            account = CardAccount.recommended.last
            expect(account.card).to eq @card
            expect(account.user).to eq @user
            expect(account.recommended_at).to be_within(5.seconds).of(
              Time.now
            )
          end

          pending "notifies the user"
        end
      end
    end

    def card_account_selector(account)
      "#card_account_#{account.id}"
    end

  end
end

