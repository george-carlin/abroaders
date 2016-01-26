require "rails_helper"

describe "admin section" do
  describe "show user page" do
    subject { page }

    include_context "logged in as admin"

    before do
      @cards = [
        @chase_business = create(:card, :business, bank: :chase),
        @chase_personal = create(:card, :personal, bank: :chase),
        @usb_business   = create(:card, :business, bank: :us_bank),
        @usb_personal   = create(:card, :personal, bank: :us_bank)
      ]
      @user = create(:user)
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

      it "doesn't include those cards in the 'new recommendation' form" do
        within "form#new_card_account" do
          should_not have_selector card_radio_btn(@recommended_card)
        end
      end
    end

    it "has a form to recommend a new card" do
      within "form#new_card_account" do
        @cards.each do |card|
          should have_recommendable_card(card)
          within recommendable_card_selector(card) do
            should have_selector card_radio_btn(card)
          end
        end
      end
    end

    describe "filters" do
      def should_have_recommendable_cards(*cards)
        cards.each { |card| should have_recommendable_card(card) }
      end

      def should_not_have_recommendable_cards(*cards)
        cards.each { |card| should_not have_recommendable_card(card) }
      end

      describe "the cards", js: true do
        specify "can be filtered by b/p" do
          uncheck :card_bp_filter_business
          should_have_recommendable_cards(@chase_personal, @usb_personal)
          should_not_have_recommendable_cards(@chase_business, @usb_business)
          uncheck :card_bp_filter_personal
          should_not_have_recommendable_cards(*@cards)
          check :card_bp_filter_business
          should_have_recommendable_cards(@chase_business, @usb_business)
          should_not_have_recommendable_cards(@chase_personal, @usb_personal)
          check :card_bp_filter_personal
          should_have_recommendable_cards(*@cards)
        end
      end

      specify "there is a 'filter by bank' dropdown" do
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
    end


    describe "the card account status dropdown" do
      it "is initially hidden" do
        is_expected.not_to have_field :card_account_status
      end
    end

    describe "selecting a card" do
      before do
        @card = @cards[2]
        choose :"card_account_card_id_#{@card.id}"
      end

      let(:submit) { click_button "Submit" }

      describe "and selecting 'recommend this card'" do
        before { choose :create_mode_recommendation }

        describe "and clicking 'submit'" do

          it "assigns the card to the user in the 'recommendation' stage" do
            expect{submit}.to change{CardAccount.recommended.count}.by(1)

            account = CardAccount.recommended.last
            expect(account.card).to eq @card
            expect(account.user).to eq @user
          end

          it "sets 'recommended at' to the current time" do
            submit
            account = CardAccount.recommended.last
            expect(account.recommended_at).to be_within(5.seconds).of(
              Time.now
            )
          end

          pending "notifies the user"
        end
      end

      describe "and selecting 'assign this card'", js: true do
        before { choose :create_mode_assignment }

        it "shows the card account status dropdown" do
          is_expected.to have_field :card_account_status
        end

        describe "selecting a status and submitting" do
          before { select "Denied", from: :card_account_status }

          let(:submit) { click_button "Submit" }

          it "assigns the card to the user in the 'recommendation' stage" do
            expect{submit}.to change{CardAccount.count}.by(1)

            account = CardAccount.last
            expect(account.card).to eq @card
            expect(account.user).to eq @user
            expect(account.status).to eq "denied"
          end

          it "doesn't set a 'recommended at' timestamp" do
            submit
            account = CardAccount.last
            expect(account.recommended_at).to be_nil
          end

          pending "notifies the user"
        end
      end
    end

    def card_account_selector(account)
      "#card_account_#{account.id}"
    end

    def card_radio_btn(card)
      "input#card_account_card_id_#{card.id}"
    end

    def have_recommendable_card(card)
      have_selector recommendable_card_selector(card)
    end

    def recommendable_card_selector(card)
      "##{dom_id(card, :admin_recommend)}"
    end

  end
end

